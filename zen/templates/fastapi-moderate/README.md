# {{project_name}}

A FastAPI application with authentication, database integration, and production-ready features.

## Features

- **Authentication & Authorization**: JWT-based authentication with role-based access control
- **Database Integration**: PostgreSQL with SQLAlchemy 2.0 and async support
- **API Structure**: Versioned API with proper routing and middleware
- **Security**: Security headers, CORS, input validation, and password hashing
- **Caching**: Redis integration for performance optimization
- **Docker Support**: Multi-stage Dockerfile and Docker Compose configurations
- **Production Ready**: Nginx reverse proxy, health checks, and monitoring

## Quick Start

### Prerequisites

- Python 3.8+
- Docker and Docker Compose (optional)
- PostgreSQL (if not using Docker)
- Redis (if not using Docker)

### Local Development

1. **Clone and setup**:
   ```bash
   cd {{project_name}}
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. **Install dependencies**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements-dev.txt
   ```

3. **Setup database**:
   ```bash
   # Make sure PostgreSQL is running
   alembic upgrade head
   ```

4. **Run the application**:
   ```bash
   uvicorn app.main:app --reload
   ```

5. **Access the API**:
   - API Documentation: http://localhost:8000/docs
   - Health Check: http://localhost:8000/health
   - API Base: http://localhost:8000/api/v1

### Docker Development

1. **Start services**:
   ```bash
   docker-compose up -d
   ```

2. **Run migrations**:
   ```bash
   docker-compose exec api alembic upgrade head
   ```

3. **Access services**:
   - API: http://localhost:8000
   - PostgreSQL: localhost:5432
   - Redis: localhost:6379
   - pgAdmin: http://localhost:5050 (admin@example.com / admin)

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user
- `POST /api/v1/auth/refresh` - Refresh access token
- `GET /api/v1/auth/me` - Get current user profile
- `POST /api/v1/auth/logout` - Logout user

### User Management
- `GET /api/v1/users/me` - Get current user info
- `PUT /api/v1/users/me` - Update current user
- `PUT /api/v1/users/me/password` - Change password
- `GET /api/v1/users/` - List users (admin/moderator only)
- `GET /api/v1/users/{user_id}` - Get user by ID (admin/moderator only)
- `PUT /api/v1/users/{user_id}` - Update user (admin only)
- `DELETE /api/v1/users/{user_id}` - Delete user (admin only)

## Database Migrations

### Create a new migration:
```bash
alembic revision --autogenerate -m "Description of changes"
```

### Apply migrations:
```bash
alembic upgrade head
```

### Rollback migration:
```bash
alembic downgrade -1
```

## Testing

### Run tests:
```bash
pytest
```

### Run tests with coverage:
```bash
pytest --cov=app --cov-report=html
```

## Production Deployment

### Using Docker Compose:

1. **Setup environment**:
   ```bash
   cp .env.example .env.prod
   # Edit .env.prod with production values
   ```

2. **Deploy**:
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

3. **Run migrations**:
   ```bash
   docker-compose -f docker-compose.prod.yml exec api alembic upgrade head
   ```

### Environment Variables

Key environment variables for production:

- `SECRET_KEY`: Strong secret key for JWT tokens
- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection string
- `DEBUG`: Set to `false` for production
- `BACKEND_CORS_ORIGINS`: Allowed CORS origins

## Security Considerations

- Change default passwords and secret keys
- Use HTTPS in production
- Configure proper CORS origins
- Set up proper firewall rules
- Regular security updates
- Monitor logs and metrics

## Project Structure

```
{{project_name}}/
├── app/
│   ├── api/
│   │   ├── v1/
│   │   │   ├── auth.py          # Authentication endpoints
│   │   │   ├── users.py         # User management endpoints
│   │   │   └── router.py        # API router configuration
│   │   └── dependencies.py      # Dependency injection
│   ├── core/
│   │   ├── config.py           # Application configuration
│   │   ├── database.py         # Database setup
│   │   └── security.py         # Security utilities
│   ├── crud/
│   │   ├── base.py             # Base CRUD operations
│   │   └── user.py             # User CRUD operations
│   ├── middleware/
│   │   ├── cors.py             # CORS middleware
│   │   ├── logging.py          # Request logging
│   │   └── security.py         # Security headers
│   ├── models/
│   │   └── user.py             # Database models
│   ├── schemas/
│   │   └── user.py             # Pydantic schemas
│   └── main.py                 # FastAPI application
├── migrations/                 # Alembic migrations
├── tests/                      # Test files
├── deployment/                 # Deployment configurations
├── docker-compose.yml          # Development Docker setup
├── docker-compose.prod.yml     # Production Docker setup
├── Dockerfile                  # Docker image definition
├── requirements.txt            # Production dependencies
├── requirements-dev.txt        # Development dependencies
└── alembic.ini                # Alembic configuration
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run tests and ensure they pass
6. Submit a pull request

## License

This project is licensed under the MIT License.