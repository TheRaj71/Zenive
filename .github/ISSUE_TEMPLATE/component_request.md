---
name: Component request
about: Request a new component for the zen ecosystem
title: '[COMPONENT] '
labels: 'component-request'
assignees: ''
---

## 🧩 Component Description

A clear and concise description of the component you'd like to see created.

## 🎯 Use Case

**What problem would this component solve?**
Describe the specific use case and why this component would be valuable.

## 📋 Component Specification

**Component Details:**
- **Name**: `component-name`
- **Category**: [e.g. utils, auth, data, services]
- **Description**: Brief description of functionality

**Expected Files:**
- `main.py` - Main component logic
- `__init__.py` - Module initialization
- `requirements.txt` - Dependencies
- Other files as needed

## 🔧 Functionality Requirements

**Core Features:**
- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3

**Optional Features:**
- [ ] Optional feature 1
- [ ] Optional feature 2

## 💻 Usage Example

**How would developers use this component?**

```python
# Example usage after installation with:
# zen add https://github.com/user/repo/component-name

from src.utils.component_name import ComponentClass

# Usage example
component = ComponentClass()
result = component.do_something()
```

## 📦 Dependencies

**What external libraries would this component need?**
- `library1` - For functionality X
- `library2` - For functionality Y

## 🎨 API Design

**What should the public interface look like?**

```python
class ComponentName:
    def __init__(self, config: dict):
        """Initialize the component."""
        pass
    
    def main_method(self, input_data: str) -> str:
        """Main functionality."""
        pass
```

## 🔗 Similar Components

**Are there existing solutions that could be referenced?**
- Link to similar libraries or components
- What would make this component different/better?

## 📚 Documentation Needs

**What documentation should be included?**
- [ ] README with usage examples
- [ ] API documentation
- [ ] Configuration guide
- [ ] Troubleshooting guide

## 🧪 Testing Requirements

**What should be tested?**
- [ ] Core functionality
- [ ] Error handling
- [ ] Edge cases
- [ ] Integration with zen

## 🏷️ Priority

How important is this component to you?

- [ ] Critical - Blocking my project
- [ ] High - Would significantly help my workflow
- [ ] Medium - Nice to have for the ecosystem
- [ ] Low - Interesting idea for the future

## 🤝 Contribution

**Are you willing to help create this component?**
- [ ] Yes, I can implement it
- [ ] Yes, I can help with design/testing
- [ ] Yes, I can provide feedback and testing
- [ ] No, but I would use it

## ✅ Checklist

- [ ] I have searched existing components to avoid duplicates
- [ ] I have provided a clear use case
- [ ] I have thought about the API design
- [ ] I have considered dependencies and complexity