#!/bin/bash

# Script to publish zen to PyPI
# Make sure you have your PyPI API token ready

echo "🚀 Publishing zen v1.1.1 to PyPI"
echo "=================================="

# Check if we're in a git repo and everything is committed
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ You have uncommitted changes. Please commit them first."
    exit 1
fi

# Install/upgrade build tools
echo "📦 Installing build tools..."
python -m pip install --upgrade pip
python -m pip install --upgrade build twine

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf dist/ build/ *.egg-info/

# Build the package
echo "🔨 Building package..."
python -m build

# Check the built package
echo "🔍 Checking package..."
python -m twine check dist/*

if [ $? -ne 0 ]; then
    echo "❌ Package check failed. Please fix the issues above."
    exit 1
fi

echo "✅ Package built successfully!"
echo ""
echo "📋 Built files:"
ls -la dist/

echo ""
echo "🚀 Ready to upload to PyPI!"
echo ""
echo "To upload to PyPI, run:"
echo "python -m twine upload dist/*"
echo ""
echo "To upload to Test PyPI first (recommended), run:"
echo "python -m twine upload --repository testpypi dist/*"
echo ""
echo "Make sure you have your PyPI API token ready!"