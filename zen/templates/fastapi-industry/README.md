# {{project_name}} - FastAPI Industry Template

Enterprise-grade FastAPI application with comprehensive production features including monitoring, observability, caching, background tasks, Kubernetes deployment, and CI/CD pipelines.

## 🚀 Features

### Core Application
- **FastAPI** with async/await support
- **SQLAlchemy 2.0** with async PostgreSQL
- **Alembic** database migrations
- **Pydantic v2** for data validation
- **JWT Authentication** with refresh tokens
- **Role-based access control (RBAC)**

### Performance & Scalability
- **Redis caching** with automatic serialization
- **Celery** distributed task queue
- **Rate limiting** with sliding window algorithm
- **Connection pooling** and query optimization
- **Horizontal pod autoscaling (HPA)**

### Monitoring & Observability
- **Prometheus metrics** collection
- **Grafana dashboards** for visualization
- **Structured logging** with JSON format
- **Sentry error tracking** integration
- **Health checks** and readiness probes
- **Correlation ID** tracking across requests

### Security
- **Security headers** middleware
- **Input validation** and sanitization
- **SQL injection** protection
- **Rate limiting** and DDoS protection
- **Secrets management** with Kubernetes secrets
- **Network policies** for pod-to-pod communication

### DevOps & Deployment
- **Kubernetes manifests** with best practices
- **Helm charts** for templated deployments
- **Terraform** infrastructure as code
- **GitHub Actions** CI/CD pipelines
- **Multi-environment** support (dev/staging/prod)
- **Blue-green deployments** with rollback

### Development Experience
- **Pre-commit hooks** for code quality
- **Comprehensive testing** (unit, integration, e2e)
- **Load testing** with Locust
- **API documentation** with OpenAPI/Swagger
- **Type hints** and MyPy validation
- **Hot reload** in development

## 📋 Prerequisites

- Python 3.9+
- Docker and Docker Compose
- PostgreSQL 15+
- Redis 7+
- Kubernetes cluster (for production)
- AWS CLI (for cloud deployment)

## 🛠️ Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone https://github.com/your-org/{{project_name}}.git
cd {{project_name}}

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements-dev.txt
```

### 2. Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your configuration
# At minimum, update these values:
# - SECRET_KEY (generate a secure key)
# - DATABASE_URL
# - REDIS_URL
# - FIRST_SUPERUSER_PASSWORD
```

### 3. Database Setup

```bash
# Start PostgreSQL and Redis with Docker
docker-compose up -d postgres redis

# Run database migrations
alembic upgrade head

# Create initial superuser (optional)
python -c "
from app.core.database import get_db_session
from app.crud.user import create_user
from app.schemas.user import UserCreate
import asyncio

async def create_admin():
    async with get_db_session() as db:
        user = UserCreate(
            email='admin@{{project_name}}.com',
            password='changethis',
            is_superuser=True
        )
        await create_user(db, user)

asyncio.run(create_admin())
"
```

### 4. Start Development Server

```bash
# Start the FastAPI application
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Start Celery worker (in another terminal)
celery -A app.worker.celery_app worker --loglevel=info

# Start Celery beat scheduler (in another terminal)
celery -A app.worker.celery_app beat --loglevel=info
```

### 5. Access the Application

- **API Documentation**: http://localhost:8000/docs
- **Health Check**: http://localhost:8000/health
- **Metrics**: http://localhost:8000/metrics
- **API Base**: http://localhost:8000/api/v1

## 🧪 Testing

### Run All Tests

```bash
# Unit tests
pytest tests/unit/ -v

# Integration tests
pytest tests/integration/ -v

# API tests
pytest tests/api/ -v

# Load tests
locust -f tests/load/locustfile.py --host=http://localhost:8000
```

### Test Coverage

```bash
# Generate coverage report
pytest --cov=app --cov-report=html --cov-report=term

# View HTML report
open htmlcov/index.html
```

## 🐳 Docker Deployment

### Development

```bash
# Build and start all services
docker-compose up --build

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f api
```

### Production

```bash
# Build production images
docker-compose -f docker-compose.prod.yml build

# Deploy to production
docker-compose -f docker-compose.prod.yml up -d
```

## ☸️ Kubernetes Deployment

### Prerequisites

```bash
# Install kubectl, helm, and configure cluster access
kubectl cluster-info

# Create namespace
kubectl apply -f deployment/k8s/namespace.yaml
```

### Deploy to Kubernetes

```bash
# Apply all manifests
kubectl apply -f deployment/k8s/

# Check deployment status
kubectl get pods -n {{project_name}}
kubectl get services -n {{project_name}}

# View logs
kubectl logs -f deployment/{{project_name}}-api -n {{project_name}}
```

### Monitoring Setup

```bash
# Install Prometheus and Grafana (using Helm)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Default login: admin/prom-operator
```

## 🏗️ Infrastructure as Code

### Terraform Deployment

```bash
cd deployment/terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="terraform.tfvars"

# Apply infrastructure
terraform apply -var-file="terraform.tfvars"

# Get outputs
terraform output
```

### AWS EKS Setup

```bash
# Configure AWS CLI
aws configure

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name {{project_name}}-production

# Verify connection
kubectl get nodes
```

## 🔄 CI/CD Pipeline

### GitHub Actions

The project includes comprehensive CI/CD pipelines:

- **CI Pipeline** (`.github/workflows/ci.yml`):
  - Code quality checks (Black, Ruff, MyPy)
  - Security scanning (Bandit, Safety)
  - Unit and integration tests
  - Load testing
  - Docker image building and scanning

- **CD Pipeline** (`.github/workflows/cd.yml`):
  - Automated deployment to staging
  - End-to-end testing
  - Security scanning (OWASP ZAP)
  - Production deployment with approval
  - Rollback on failure

- **Security Pipeline** (`.github/workflows/security.yml`):
  - Daily vulnerability scans
  - Dependency checking
  - Container security scanning
  - Infrastructure security validation

### Required Secrets

Configure these secrets in your GitHub repository:

```bash
# AWS Credentials
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION

# Database
DB_PASSWORD

# Application
SECRET_KEY
SENTRY_DSN

# Notifications
SLACK_WEBHOOK_URL

# Security Tools
SNYK_TOKEN
SONAR_TOKEN
```

## 📊 Monitoring and Observability

### Metrics

The application exposes Prometheus metrics at `/metrics`:

- HTTP request metrics (count, duration, status codes)
- Database connection metrics
- Cache hit/miss rates
- Background task metrics
- Custom business metrics

### Logging

Structured JSON logging with:

- Correlation IDs for request tracing
- Performance metrics
- Security events
- Business events
- Error context and stack traces

### Dashboards

Pre-configured Grafana dashboards for:

- Application overview
- API performance
- Database metrics
- Cache performance
- Error rates and alerts

### Alerting

Prometheus alerting rules for:

- High error rates (>5%)
- High response times (>2s)
- Application downtime
- High resource usage
- Database connection issues

## 🔧 Configuration

### Environment Variables

Key configuration options:

```bash
# Application
PROJECT_NAME={{project_name}}
ENVIRONMENT=production
DEBUG=false

# Database
DATABASE_URL=postgresql+asyncpg://user:pass@host:5432/db
DB_POOL_SIZE=20

# Cache
REDIS_URL=redis://host:6379/0
CACHE_DEFAULT_TTL=300

# Security
SECRET_KEY=your-secret-key
RATE_LIMIT_REQUESTS=1000
RATE_LIMIT_WINDOW=60

# Monitoring
SENTRY_DSN=https://your-dsn@sentry.io/project
METRICS_ENABLED=true
LOG_LEVEL=INFO
```

### Feature Flags

Toggle features using environment variables:

```bash
FEATURE_FLAGS={
  "new_user_registration": true,
  "email_verification": true,
  "two_factor_auth": false,
  "api_versioning": true
}
```

## 🚀 Performance Optimization

### Database

- Connection pooling with SQLAlchemy
- Query optimization with indexes
- Read replicas for scaling reads
- Connection monitoring and alerting

### Caching

- Redis for application-level caching
- Automatic cache invalidation
- Cache warming strategies
- Cache hit rate monitoring

### API Performance

- Async/await throughout the stack
- Response compression
- Rate limiting to prevent abuse
- Request/response size monitoring

## 🔒 Security Best Practices

### Application Security

- Input validation with Pydantic
- SQL injection prevention
- XSS protection with security headers
- CSRF protection for state-changing operations
- Secure password hashing with bcrypt

### Infrastructure Security

- Network policies for pod isolation
- Secrets management with Kubernetes secrets
- Regular security scanning in CI/CD
- Vulnerability monitoring with Snyk/Trivy
- Security headers enforcement

### Compliance

- GDPR-ready user data handling
- Audit logging for compliance
- Data encryption at rest and in transit
- Regular security assessments

## 📚 API Documentation

### Interactive Documentation

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/api/v1/openapi.json

### API Endpoints

#### Authentication
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - User logout

#### Users
- `GET /api/v1/users/me` - Get current user
- `PUT /api/v1/users/me` - Update current user
- `GET /api/v1/users/` - List users (admin only)
- `POST /api/v1/users/` - Create user (admin only)

#### Health & Monitoring
- `GET /health` - Application health check
- `GET /health/ready` - Readiness probe
- `GET /health/live` - Liveness probe
- `GET /metrics` - Prometheus metrics

## 🤝 Contributing

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Install pre-commit hooks: `pre-commit install`
4. Make your changes
5. Run tests: `pytest`
6. Submit a pull request

### Code Style

- Use Black for code formatting
- Follow PEP 8 guidelines
- Add type hints for all functions
- Write docstrings for public APIs
- Maintain test coverage >90%

### Commit Messages

Follow conventional commits:

```
feat: add user profile endpoints
fix: resolve database connection issue
docs: update API documentation
test: add integration tests for auth
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Documentation

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)

### Getting Help

- Create an issue for bug reports
- Use discussions for questions
- Check existing issues before creating new ones
- Provide minimal reproduction examples

### Troubleshooting

Common issues and solutions:

1. **Database connection errors**: Check DATABASE_URL and ensure PostgreSQL is running
2. **Redis connection errors**: Verify REDIS_URL and Redis server status
3. **Import errors**: Ensure all dependencies are installed with `pip install -r requirements.txt`
4. **Permission errors**: Check file permissions and user access rights
5. **Port conflicts**: Ensure ports 8000, 5432, and 6379 are available

## 🗺️ Roadmap

### Upcoming Features

- [ ] GraphQL API support
- [ ] WebSocket real-time features
- [ ] Multi-tenant architecture
- [ ] Advanced caching strategies
- [ ] Machine learning integration
- [ ] Mobile app backend features

### Performance Improvements

- [ ] Database query optimization
- [ ] CDN integration
- [ ] Edge computing support
- [ ] Advanced monitoring metrics
- [ ] Automated performance testing

---

**Built with ❤️ using FastAPI Industry Template**

For more information, visit the [project documentation](https://{{project_name}}.readthedocs.io/) or contact the development team.