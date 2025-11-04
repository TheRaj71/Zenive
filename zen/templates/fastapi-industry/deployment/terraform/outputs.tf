# FastAPI Industry Template - Terraform Outputs
# Comprehensive outputs for infrastructure components

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

output "nat_gateway_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

# EKS Cluster Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if enabled"
  value       = module.eks.oidc_provider_arn
}

# Node Group Outputs
output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks.eks_managed_node_groups
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = module.eks.node_security_group_id
}

# RDS Outputs
output "db_instance_address" {
  description = "RDS instance hostname"
  value       = module.rds.db_instance_address
  sensitive   = true
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = module.rds.db_instance_arn
}

output "db_instance_availability_zone" {
  description = "RDS instance availability zone"
  value       = module.rds.db_instance_availability_zone
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = module.rds.db_instance_id
}

output "db_instance_name" {
  description = "RDS instance name"
  value       = module.rds.db_instance_name
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = module.rds.db_instance_port
}

output "db_instance_username" {
  description = "RDS instance root username"
  value       = module.rds.db_instance_username
  sensitive   = true
}

output "db_subnet_group_id" {
  description = "RDS subnet group ID"
  value       = module.rds.db_subnet_group_id
}

output "db_subnet_group_arn" {
  description = "RDS subnet group ARN"
  value       = module.rds.db_subnet_group_arn
}

# ElastiCache Redis Outputs
output "redis_cluster_id" {
  description = "ElastiCache Redis cluster ID"
  value       = aws_elasticache_replication_group.redis.id
}

output "redis_cluster_arn" {
  description = "ElastiCache Redis cluster ARN"
  value       = aws_elasticache_replication_group.redis.arn
}

output "redis_primary_endpoint_address" {
  description = "ElastiCache Redis primary endpoint address"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
  sensitive   = true
}

output "redis_reader_endpoint_address" {
  description = "ElastiCache Redis reader endpoint address"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
  sensitive   = true
}

output "redis_port" {
  description = "ElastiCache Redis port"
  value       = aws_elasticache_replication_group.redis.port
}

# S3 Outputs
output "s3_bucket_id" {
  description = "S3 bucket ID for application data"
  value       = aws_s3_bucket.app_data.id
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN for application data"
  value       = aws_s3_bucket.app_data.arn
}

output "s3_bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = aws_s3_bucket.app_data.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  value       = aws_s3_bucket.app_data.bucket_regional_domain_name
}

# IAM Outputs
output "app_role_arn" {
  description = "ARN of the application IAM role"
  value       = aws_iam_role.app_role.arn
}

output "app_role_name" {
  description = "Name of the application IAM role"
  value       = aws_iam_role.app_role.name
}

# Secrets Manager Outputs
output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "secrets_manager_secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.app_secrets.name
}

# CloudWatch Outputs
output "app_log_group_name" {
  description = "Name of the application CloudWatch log group"
  value       = aws_cloudwatch_log_group.app_logs.name
}

output "app_log_group_arn" {
  description = "ARN of the application CloudWatch log group"
  value       = aws_cloudwatch_log_group.app_logs.arn
}

output "worker_log_group_name" {
  description = "Name of the worker CloudWatch log group"
  value       = aws_cloudwatch_log_group.worker_logs.name
}

output "worker_log_group_arn" {
  description = "ARN of the worker CloudWatch log group"
  value       = aws_cloudwatch_log_group.worker_logs.arn
}

# Security Group Outputs
output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "redis_security_group_id" {
  description = "ID of the Redis security group"
  value       = aws_security_group.redis.id
}

output "additional_security_group_id" {
  description = "ID of the additional security group"
  value       = aws_security_group.additional.id
}

# Connection Information
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_id}"
}

output "database_connection_string" {
  description = "Database connection string (without password)"
  value       = "postgresql://${module.rds.db_instance_username}@${module.rds.db_instance_endpoint}/${module.rds.db_instance_name}"
  sensitive   = true
}

output "redis_connection_string" {
  description = "Redis connection string (without auth token)"
  value       = "redis://${aws_elasticache_replication_group.redis.primary_endpoint_address}:${aws_elasticache_replication_group.redis.port}/0"
  sensitive   = true
}

# Environment Information
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = local.cluster_name
}

# Monitoring Endpoints
output "prometheus_endpoint" {
  description = "Prometheus endpoint (if monitoring is enabled)"
  value       = var.enable_monitoring ? "http://prometheus.${var.project_name}.local" : null
}

output "grafana_endpoint" {
  description = "Grafana endpoint (if monitoring is enabled)"
  value       = var.enable_monitoring ? "http://grafana.${var.project_name}.local" : null
}

# Application URLs
output "api_endpoint" {
  description = "API endpoint URL"
  value       = var.domain_name != "" ? "https://api.${var.domain_name}" : "http://${module.eks.cluster_endpoint}"
}

output "health_check_url" {
  description = "Health check URL"
  value       = var.domain_name != "" ? "https://api.${var.domain_name}/health" : "http://${module.eks.cluster_endpoint}/health"
}

output "metrics_url" {
  description = "Metrics endpoint URL"
  value       = var.domain_name != "" ? "https://api.${var.domain_name}/metrics" : "http://${module.eks.cluster_endpoint}/metrics"
}

# Cost Information
output "estimated_monthly_cost" {
  description = "Estimated monthly cost (approximate)"
  value = {
    eks_cluster = "~$73/month"
    rds_instance = var.db_instance_class == "db.t3.micro" ? "~$15/month" : "varies"
    redis_cache = var.redis_node_type == "cache.t3.micro" ? "~$15/month" : "varies"
    nat_gateway = var.enable_nat_gateway ? (var.single_nat_gateway ? "~$45/month" : "~$135/month") : "$0"
    note = "Actual costs may vary based on usage and data transfer"
  }
}

# Deployment Information
output "deployment_timestamp" {
  description = "Timestamp of the deployment"
  value       = timestamp()
}

output "terraform_version" {
  description = "Terraform version used for deployment"
  value       = "~> 1.0"
}