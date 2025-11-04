# {{project_name}}

{{description}}

A minimal FastAPI application with example endpoints, proper error handling, and configuration management.

## Features

- ✅ FastAPI with automatic OpenAPI documentation
- ✅ Pydantic models with validation
- ✅ Environment-based configuration
- ✅ Structured logging
- ✅ CORS middleware
- ✅ Global exception handling
- ✅ Health check endpoint
- ✅ CRUD operations example
- ✅ Development and production settings

## Quick Start

### Prerequisites

- Python 3.8 or higher
- pip or poetry for dependency management

### Installation

1. **Clone or create your project:**
   ```bash
   # If using zen template system
   zen create {{project_name}} --template fastapi-minimal
   
   # Or manually clone/download the template
   ```

2. **Install dependencies:**
   ```bash
   # Production dependencies
   pip install -r requirements.txt
   
   # Or with development dependencies
   pip install -r requirements-dev.txt
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Run the application:**
   ```bash
   # Development mode (with auto-reload)
   uvicorn app.main:app --reload
   
   # Or using Python
   python -m app.main
   
   # Production mode
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```

5. **Access the application:**
   - API: http://127.0.0.1:8000
   - Interactive docs: http://127.0.0.1:8000/docs
   - Alternative docs: http://127.0.0.1:8000/redoc

## API Endpoints

### Core Endpoints

- `GET /` - Welcome message and API info
- `GET /health` - Health check endpoint

### Items CRUD

- `GET /items` - Get all items
- `GET /items/{item_id}` - Get specific item
- `POST /items` - Create new item
- `PUT /items/{item_id}` - Update existing item
- `DELETE /items/{item_id}` - Delete item

### Example Usage

```bash
# Create an item
curl -X POST "http://127.0.0.1:8000/items" \
     -H "Content-Type: application/json" \
     -d '{"name": "Example Item", "description": "A sample item", "price": 29.99}'

# Get all items
curl "http://127.0.0.1:8000/items"

# Get specific item
curl "http://127.0.0.1:8000/items/1"
```

## Configuration

The application uses environment variables for configuration. Copy `.env.example` to `.env` and modify as needed:

```env
# Application
APP_NAME={{project_name}}
ENVIRONMENT=development
DEBUG=true

# Server
HOST=127.0.0.1
PORT=8000

# Logging
LOG_LEVEL=INFO

# CORS
ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
```

## Development

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app

# Run specific test file
pytest tests/test_main.py
```

### Code Quality

```bash
# Format code
black app/ tests/

# Sort imports
isort app/ tests/

# Lint code
flake8 app/ tests/

# Type checking
mypy app/
```

### Project Structure

```
{{project_name}}/
├── app/
│   ├── __init__.py
│   ├── main.py          # FastAPI application and routes
│   ├── models.py        # Pydantic models
│   └── config.py        # Configuration management
├── tests/
│   ├── __init__.py
│   └── test_main.py     # API tests
├── requirements.txt     # Production dependencies
├── requirements-dev.txt # Development dependencies
├── .env.example        # Environment variables template
├── .gitignore          # Git ignore patterns
└── README.md           # This file
```

## Deployment

### Docker (Optional)

Create a `Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Environment Variables for Production

Make sure to set these environment variables in production:

- `ENVIRONMENT=production`
- `DEBUG=false`
- `SECRET_KEY=your-secure-secret-key`
- `HOST=0.0.0.0`
- `PORT=8000`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Created by {{author_name}}

---

**Happy coding! 🚀**