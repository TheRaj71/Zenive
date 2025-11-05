# Contributing to zen

Thank you for your interest in contributing to zen! We welcome contributions from everyone and are grateful for every pull request.

## 🚀 Quick Start

1. Fork the repository
2. Clone your fork: `git clone https://github.com/TheRaj71/Zenive.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes
6. Commit your changes: `git commit -m "Add your feature"`
7. Push to your branch: `git push origin feature/your-feature-name`
8. Open a Pull Request

## 📋 Development Setup

### Prerequisites

- Python 3.8 or higher
- pip or poetry for dependency management
- Git

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/TheRaj71/Zenive.git
   cd Zenive
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   pip install -e .  # Install in development mode
   ```

4. **Run tests**
   ```bash
   python -m pytest
   ```

## 🎯 How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Environment details** (OS, Python version, zen version)
- **Code samples** or error messages if applicable

### Suggesting Features

We love feature suggestions! Please:

- **Check existing issues** for similar requests
- **Describe the feature** clearly and concisely
- **Explain the use case** and why it would be valuable
- **Consider implementation** if you have ideas

### Code Contributions

#### Types of Contributions Welcome

- **Bug fixes**
- **New features**
- **Documentation improvements**
- **Performance optimizations**
- **Test coverage improvements**
- **Code quality improvements**

#### Coding Standards

- **Follow PEP 8** for Python code style
- **Use type hints** where appropriate
- **Write docstrings** for functions and classes
- **Keep functions small** and focused
- **Use meaningful variable names**

#### Example Code Style

```python
from typing import List, Optional

def validate_component_config(config: dict) -> bool:
    """
    Validate component configuration structure.
    
    Args:
        config: Component configuration dictionary
        
    Returns:
        True if valid, False otherwise
        
    Raises:
        ValueError: If required fields are missing
    """
    required_fields = ["name", "version", "files"]
    
    for field in required_fields:
        if field not in config:
            raise ValueError(f"Missing required field: {field}")
    
    return True
```

#### Testing Guidelines

- **Write tests** for new features and bug fixes
- **Maintain test coverage** above 80%
- **Use descriptive test names**
- **Test edge cases** and error conditions

```python
def test_validate_component_config_missing_name():
    """Test that validation fails when name field is missing."""
    config = {"version": "1.0.0", "files": []}
    
    with pytest.raises(ValueError, match="Missing required field: name"):
        validate_component_config(config)
```

## 📁 Project Structure

```
Zenive/
├── zen/                    # Main package
│   ├── cli/               # Command-line interface
│   ├── core/              # Core functionality
│   └── schemas/           # Data schemas
├── components/            # Example components
├── docs/                  # Documentation
├── tests/                 # Test suite
├── scripts/               # Utility scripts
└── requirements.txt       # Dependencies
```

## 🔄 Pull Request Process

### Before Submitting

1. **Update documentation** if needed
2. **Add tests** for new functionality
3. **Run the test suite** and ensure all tests pass
4. **Update CHANGELOG.md** if applicable
5. **Ensure code follows** our style guidelines

### Pull Request Guidelines

- **Use a clear title** that describes the change
- **Reference related issues** using `Fixes #123` or `Closes #123`
- **Provide detailed description** of changes made
- **Include screenshots** for UI changes
- **Keep PRs focused** - one feature/fix per PR

### PR Template

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Other (please describe)

## Testing
- [ ] Tests pass locally
- [ ] Added tests for new functionality
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
python -m pytest

# Run with coverage
python -m pytest --cov=zen

# Run specific test file
python -m pytest tests/test_cli.py

# Run with verbose output
python -m pytest -v
```

### Writing Tests

- Place tests in the `tests/` directory
- Mirror the package structure in test files
- Use descriptive test function names
- Test both success and failure cases

## 📚 Documentation

### Documentation Standards

- **Keep README.md updated** with new features
- **Document all public APIs** with docstrings
- **Include examples** in documentation
- **Update relevant docs** in the `docs/` folder

### Building Documentation

```bash
# Generate API documentation
python -m pydoc zen

# Serve documentation locally (if using mkdocs)
mkdocs serve
```

## 🏷️ Release Process

Releases are handled by maintainers following semantic versioning:

- **Patch** (1.0.1): Bug fixes
- **Minor** (1.1.0): New features, backward compatible
- **Major** (2.0.0): Breaking changes

## 🤝 Community Guidelines

- **Be respectful** and inclusive
- **Help newcomers** get started
- **Provide constructive feedback**
- **Follow our Code of Conduct**

## 💡 Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Documentation**: Check the `docs/` folder for detailed guides

## 🎉 Recognition

Contributors are recognized in:

- **CHANGELOG.md** for significant contributions
- **README.md** contributors section
- **GitHub contributors** page

## 📄 License

By contributing to zen, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to zen! Your efforts help make Python component management better for everyone. 🚀