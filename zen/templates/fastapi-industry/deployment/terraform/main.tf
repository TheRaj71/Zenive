# FastAPI Industry Template - Terraform Infrastructure
# Comprehensive infrastructure setup for AWS with EKS, RDS, ElastiCache, and monitoring

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
  
  backend "s3" {
    # Configure your S3 backend
    bucket = "{{project_name}}-terraform-state"
    key    = "infrastructure/terraform.tfstate"
    region = "us-west-2"
    
    # Enable state locking
    dynamodb_table = "{{project_name}}-terraform-locks"
    encrypt        = true
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Local values
locals {
  cluster_name = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
  }
  
  # Subnet configuration
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
}

# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.cluster_name}-vpc"
  cidr = local.vpc_cidr

  azs              = local.azs
  private_subnets  = local.private_subnets
  public_subnets   = local.public_subnets
  database_subnets = local.database_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = var.environment == "development"
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Enable flow logs
  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  # Kubernetes tags
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  tags = local.common_tags
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  # Cluster access entry
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    main = {
      name = "${local.cluster_name}-main"
      
      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"
      
      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      # Launch template configuration
      create_launch_template = false
      launch_template_name   = ""

      disk_size = 50
      ami_type  = "AL2_x86_64"

      # Remote access
      remote_access = {
        ec2_ssh_key               = var.key_pair_name
        source_security_group_ids = [aws_security_group.additional.id]
      }

      # Kubernetes labels
      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      # Kubernetes taints
      taints = []

      tags = local.common_tags
    }

    # Spot instances for non-critical workloads
    spot = {
      name = "${local.cluster_name}-spot"
      
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "SPOT"
      
      min_size     = 0
      max_size     = 5
      desired_size = 2

      disk_size = 30
      ami_type  = "AL2_x86_64"

      labels = {
        Environment = var.environment
        NodeGroup   = "spot"
        WorkloadType = "non-critical"
      }

      taints = [
        {
          key    = "spot-instance"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]

      tags = merge(local.common_tags, {
        NodeType = "spot"
      })
    }
  }

  # Cluster security group additional rules
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # Node security group additional rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  tags = local.common_tags
}

# Additional security group for remote access
resource "aws_security_group" "additional" {
  name_prefix = "${local.cluster_name}-additional"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }

  tags = local.common_tags
}

# RDS PostgreSQL Database
module "rds" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${local.cluster_name}-postgres"

  # Database configuration
  engine               = "postgres"
  engine_version       = var.postgres_version
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_encrypted     = true

  # Database settings
  db_name  = replace(var.project_name, "-", "_")
  username = var.db_username
  port     = 5432

  # Network configuration
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Backup configuration
  backup_retention_period = var.environment == "production" ? 30 : 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Sun:04:00-Sun:05:00"

  # Monitoring
  monitoring_interval    = 60
  monitoring_role_name   = "${local.cluster_name}-rds-monitoring"
  create_monitoring_role = true

  # Performance Insights
  performance_insights_enabled = var.environment == "production"
  performance_insights_retention_period = var.environment == "production" ? 7 : null

  # Enhanced monitoring
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Multi-AZ for production
  multi_az = var.environment == "production"

  # Deletion protection for production
  deletion_protection = var.environment == "production"
  skip_final_snapshot = var.environment != "production"

  tags = local.common_tags
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name_prefix = "${local.cluster_name}-rds"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-rds"
  })
}

# ElastiCache Redis Cluster
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${local.cluster_name}-redis"
  subnet_ids = module.vpc.private_subnets

  tags = local.common_tags
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id         = "${local.cluster_name}-redis"
  description                  = "Redis cluster for ${var.project_name}"
  
  node_type                    = var.redis_node_type
  port                         = 6379
  parameter_group_name         = "default.redis7"
  
  num_cache_clusters           = var.redis_num_cache_nodes
  
  # Network configuration
  subnet_group_name            = aws_elasticache_subnet_group.redis.name
  security_group_ids           = [aws_security_group.redis.id]
  
  # Security
  at_rest_encryption_enabled   = true
  transit_encryption_enabled   = true
  auth_token                   = var.redis_auth_token
  
  # Backup
  snapshot_retention_limit     = var.environment == "production" ? 7 : 1
  snapshot_window              = "03:00-05:00"
  
  # Maintenance
  maintenance_window           = "sun:05:00-sun:07:00"
  
  # Automatic failover for multi-node clusters
  automatic_failover_enabled   = var.redis_num_cache_nodes > 1
  multi_az_enabled            = var.redis_num_cache_nodes > 1

  tags = local.common_tags
}

# Redis Security Group
resource "aws_security_group" "redis" {
  name_prefix = "${local.cluster_name}-redis"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-redis"
  })
}

# S3 Bucket for application data
resource "aws_s3_bucket" "app_data" {
  bucket = "${var.project_name}-${var.environment}-app-data-${random_id.bucket_suffix.hex}"

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "app_data" {
  bucket = aws_s3_bucket.app_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/eks/${local.cluster_name}/application"
  retention_in_days = var.environment == "production" ? 30 : 7

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "worker_logs" {
  name              = "/aws/eks/${local.cluster_name}/worker"
  retention_in_days = var.environment == "production" ? 30 : 7

  tags = local.common_tags
}

# IAM Role for application pods
resource "aws_iam_role" "app_role" {
  name = "${local.cluster_name}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:${var.project_name}:${var.project_name}-api"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM Policy for application
resource "aws_iam_policy" "app_policy" {
  name        = "${local.cluster_name}-app-policy"
  description = "IAM policy for ${var.project_name} application"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.app_data.arn,
          "${aws_s3_bucket.app_data.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          aws_cloudwatch_log_group.app_logs.arn,
          aws_cloudwatch_log_group.worker_logs.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.app_secrets.arn
        ]
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "app_policy" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}

# Secrets Manager for application secrets
resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "${local.cluster_name}-secrets"
  description = "Application secrets for ${var.project_name}"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    database_url = "postgresql://${module.rds.db_instance_username}:${var.db_password}@${module.rds.db_instance_endpoint}/${module.rds.db_instance_name}"
    redis_url    = "redis://:${var.redis_auth_token}@${aws_elasticache_replication_group.redis.primary_endpoint_address}:6379/0"
    secret_key   = var.app_secret_key
    sentry_dsn   = var.sentry_dsn
  })
}