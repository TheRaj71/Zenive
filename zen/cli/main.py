#!/usr/bin/env python3
"""
zen CLI - Python component registry like shadcn/ui
"""

import click
import sys
from pathlib import Path
from zen.core.logger import get_logger, setup_logging
from zen.core.installer import ComponentInstaller
from zen.core.exceptions import InstallationError, ConfigurationError

logger = get_logger()

@click.group()
@click.version_option(version="1.0.0", prog_name="zen")
@click.option("--verbose", "-v", is_flag=True, help="Enable verbose logging")
def cli(verbose):
    """zen - Python component registry like shadcn/ui"""
    setup_logging(verbose=verbose)

@cli.command()
@click.argument("project_name", required=False)
@click.option("--force", "-f", is_flag=True, help="Overwrite existing project")
@click.option("--minimal", "-m", is_flag=True, help="Minimal setup (just .zen config)")
def init(project_name, force, minimal):
    """Initialize zen in a new or existing project (like shadcn/ui init)"""
    try:
        project_path = Path(project_name) if project_name else Path.cwd()
        is_existing_project = project_path.exists() and project_name is None
        
        if project_name:
            if project_path.exists() and not force:
                logger.error(f"Directory '{project_name}' already exists. Use --force to overwrite.")
                sys.exit(1)
            
            project_path.mkdir(parents=True, exist_ok=True)
            logger.info(f"Created project directory: {project_path}")
        
        # Check if this is an existing project
        if is_existing_project:
            logger.info("Initializing zen in existing project...")
            if minimal or _detect_existing_project_type():
                _initialize_zen_config()
                logger.success("✨ Successfully initialized zen (minimal setup)")
                logger.info("You can now run 'zen add <component-url>' to install components")
                return
        
        # Full project structure for new projects
        _create_project_structure(project_path)
        
        # Show success with banner
        logger.show_banner("🎉 zen Project Initialized!", "Ready to install components")
        
        next_steps = """[cyan]Next steps:[/cyan]
  [dim]1.[/dim] cd into your project directory
  [dim]2.[/dim] Run [green]zen add <component-url>[/green] to install components  
  [dim]3.[/dim] Install dependencies with [green]pip install -r requirements.txt[/green]"""
        
        from rich.panel import Panel
        logger.console.print(Panel(next_steps, border_style="cyan", padding=(1, 2)))
        
    except Exception as e:
        logger.error(f"Failed to initialize project: {e}")
        sys.exit(1)

@cli.command()
@click.argument("component_url")
@click.option("--path", "-p", help="Custom installation path")
@click.option("--overwrite", "-o", is_flag=True, help="Overwrite existing files")
@click.option("--dry-run", "-d", is_flag=True, help="Show what would be done without doing it")
@click.option("--yes", "-y", is_flag=True, help="Skip confirmation prompts")
def add(component_url, path, overwrite, dry_run, yes):
    """Install a component from URL (like shadcn/ui)
    
    Examples:
      zen add https://github.com/user/repo/component.json
      zen add https://github.com/user/components/tree/main/email-validator
      zen add https://raw.githubusercontent.com/user/repo/main/component.json
      zen add file:///path/to/component.json
    """
    try:
        # Check if we're in a zen project, if not, offer to initialize
        config_path = Path(".zen/config.yaml")
        if not config_path.exists():
            logger.warning("No zen configuration found.")
            if not yes and click.confirm("Initialize zen in this directory?"):
                _initialize_zen_config()
                logger.info("✨ Initialized zen configuration")
            elif yes:
                _initialize_zen_config()
                logger.info("✨ Initialized zen configuration")
            else:
                logger.error("Cannot install components without zen configuration.")
                logger.info("Run 'zen init' or use --yes to auto-initialize.")
                sys.exit(1)
        
        installer = ComponentInstaller()
        
        # Fetch component with spinner animation
        try:
            from zen.schemas.component import load_component_from_url
            
            with logger.spinner(f"Fetching component from {component_url}", "dots"):
                component = load_component_from_url(component_url)
            
            # Show beautiful component info
            install_path = path or installer._get_default_path(component.category)
            logger.show_component_info(
                component.name, 
                component.version, 
                component.description,
                component.category,
                component.dependencies,
                len(component.files)
            )
            logger.info(f"[cyan]📍 Install to:[/cyan] {install_path}")
            
        except Exception as e:
            logger.error(f"Failed to fetch component: {e}")
            sys.exit(1)
        
        if dry_run:
            logger.info("")
            logger.info("🔍 DRY RUN - No changes will be made")
            logger.info("Files that would be installed:")
            for file_info in component.files:
                target_path = path or file_info.path
                logger.info(f"  • {file_info.name} -> {target_path}")
            return
        
        # Confirmation prompt (unless --yes)
        if not yes:
            logger.info("")
            if not click.confirm("Proceed with installation?"):
                logger.info("Installation cancelled.")
                return
        
        logger.info("")
        
        # Install component with spinner
        with logger.spinner("Installing component files and dependencies", "arc"):
            result = installer.install_from_url(component_url, path, overwrite)
        
        # Show beautiful success summary
        logger.show_success_summary(
            result['component'],
            result['files_installed'], 
            result['dependencies_added'],
            result['install_path']
        )
        
    except (InstallationError, ConfigurationError) as e:
        logger.error(str(e))
        sys.exit(1)
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        sys.exit(1)

def _create_project_structure(project_path: Path):
    """Create the basic project structure"""
    import yaml
    
    # Create directories
    directories = [
        ".zen",
        "src",
        "src/components", 
        "src/utils",
        "src/models",
        "src/services",
        "src/auth",
        "src/data"
    ]
    
    for dir_name in directories:
        dir_path = project_path / dir_name
        dir_path.mkdir(parents=True, exist_ok=True)
        logger.debug(f"Created directory: {dir_path}")
    
    # Create config file
    config = {
        "name": project_path.name,
        "version": "1.0.0",
        "description": f"zen project: {project_path.name}",
        "structure": {
            "components": "src/components",
            "utils": "src/utils", 
            "models": "src/models",
            "services": "src/services",
            "auth": "src/auth",
            "data": "src/data"
        },
        "components": {}
    }
    
    config_path = project_path / ".zen" / "config.yaml"
    with open(config_path, "w") as f:
        yaml.dump(config, f, default_flow_style=False, indent=2)
    logger.info(f"Created configuration file: {config_path}")
    
    # Create requirements.txt with zen dependencies
    requirements_path = project_path / "requirements.txt"
    requirements_content = """# Project dependencies
# Generated by zen

# Core dependencies (uncomment if needed)
# requests>=2.25.0
# pydantic>=1.8.0
# click>=8.0.0

# Add your project dependencies below
"""
    with open(requirements_path, "w") as f:
        f.write(requirements_content)
    logger.info("Created requirements.txt")
    
    # Create .gitignore
    gitignore_path = project_path / ".gitignore"
    gitignore_content = """# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
venv/
env/
ENV/
.venv/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Project specific
.zen/cache/
"""
    with open(gitignore_path, "w") as f:
        f.write(gitignore_content)
    logger.info("Created .gitignore")
    
    # Create README.md
    readme_path = project_path / "README.md"
    readme_content = f"""# {project_path.name}

A zen project.

## Installation

Install dependencies:
```bash
pip install -r requirements.txt
```

## Adding Components

Install components from JSON URLs:
```bash
zen add https://example.com/component.json
zen add https://github.com/user/repo/component.json
```

## Project Structure

```
{project_path.name}/
├── src/
│   ├── components/    # General components
│   ├── utils/         # Utility functions
│   ├── models/        # Data models
│   ├── services/      # Business logic
│   ├── auth/          # Authentication
│   └── data/          # Data processing
├── .zen/
│   └── config.yaml    # Project configuration
├── requirements.txt   # Python dependencies
└── README.md
```

Built with [zen](https://github.com/TheRaj71/Zenive)
"""
    with open(readme_path, "w") as f:
        f.write(readme_content)
    logger.info("Created README.md")
    
    # Create __init__.py files
    init_files = [
        "src/__init__.py",
        "src/components/__init__.py",
        "src/utils/__init__.py", 
        "src/models/__init__.py",
        "src/services/__init__.py",
        "src/auth/__init__.py",
        "src/data/__init__.py"
    ]
    
    for init_file in init_files:
        init_path = project_path / init_file
        with open(init_path, "w") as f:
            f.write("")
        logger.debug(f"Created {init_path}")

@cli.command()
def list():
    """List installed components"""
    try:
        config_path = Path(".zen/config.yaml")
        if not config_path.exists():
            logger.error("Not in a zen project. Run 'zen init' first.")
            sys.exit(1)
        
        import yaml
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f) or {}
        
        components = config.get("components", {})
        
        if not components:
            logger.info("No components installed.")
            return
        
        # Show components in a beautiful table
        from rich.table import Table
        
        table = Table(title=f"📦 Installed Components ({len(components)})", show_header=True, header_style="bold cyan")
        table.add_column("Name", style="green", no_wrap=True)
        table.add_column("Version", style="blue")
        table.add_column("Category", style="yellow")
        table.add_column("Source", style="dim", overflow="ellipsis", max_width=50)
        
        for comp_name, comp_info in components.items():
            name = comp_info.get("name", comp_name)
            version = comp_info.get("version", "unknown")
            category = comp_info.get("category", "unknown")
            source = comp_info.get("source", "unknown")
            
            table.add_row(name, version, category, source)
        
        logger.console.print(table)
            
    except Exception as e:
        logger.error(f"Failed to list components: {e}")
        sys.exit(1)

@cli.command()
@click.argument("component_name")
def info(component_name):
    """Show detailed information about an installed component"""
    try:
        config_path = Path(".zen/config.yaml")
        if not config_path.exists():
            logger.error("Not in a zen project. Run 'zen init' first.")
            sys.exit(1)
        
        import yaml
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f) or {}
        
        components = config.get("components", {})
        
        if component_name not in components:
            logger.error(f"Component '{component_name}' not found.")
            logger.info("Run 'zen list' to see installed components.")
            sys.exit(1)
        
        comp_info = components[component_name]
        
        logger.info(f"📦 Component: {comp_info.get('name', component_name)}")
        logger.info(f"Version: {comp_info.get('version', 'unknown')}")
        logger.info(f"Category: {comp_info.get('category', 'unknown')}")
        logger.info(f"Source: {comp_info.get('source', 'unknown')}")
        
        deps = comp_info.get('dependencies', [])
        if deps:
            logger.info(f"Dependencies: {', '.join(deps)}")
        
    except Exception as e:
        logger.error(f"Failed to show component info: {e}")
        sys.exit(1)

@cli.command()
@click.argument("component_name")
@click.option("--force", "-f", is_flag=True, help="Force removal without confirmation")
def remove(component_name, force):
    """Remove an installed component"""
    try:
        config_path = Path(".zen/config.yaml")
        if not config_path.exists():
            logger.error("Not in a zen project. Run 'zen init' first.")
            sys.exit(1)
        
        import yaml
        with open(config_path, 'r') as f:
            config = yaml.safe_load(f) or {}
        
        components = config.get("components", {})
        
        if component_name not in components:
            logger.error(f"Component '{component_name}' not found.")
            sys.exit(1)
        
        comp_info = components[component_name]
        
        if not force:
            logger.info(f"This will remove component: {comp_info.get('name', component_name)}")
            logger.warning("Note: Files will not be automatically deleted.")
            logger.warning("You may need to manually remove files and clean up dependencies.")
            
            if not click.confirm("Continue?"):
                logger.info("Removal cancelled.")
                return
        
        # Remove from config
        del components[component_name]
        config["components"] = components
        
        with open(config_path, 'w') as f:
            yaml.dump(config, f, default_flow_style=False, indent=2)
        
        logger.success(f"✨ Removed component: {component_name}")
        logger.info("💡 Consider manually removing files and cleaning up dependencies.")
        
    except Exception as e:
        logger.error(f"Failed to remove component: {e}")
        sys.exit(1)

def _detect_existing_project_type():
    """Detect if this is an existing Python project"""
    indicators = [
        "setup.py", "pyproject.toml", "requirements.txt", 
        "Pipfile", "poetry.lock", "src/", "app.py", "main.py"
    ]
    return any(Path(indicator).exists() for indicator in indicators)

def _initialize_zen_config():
    """Initialize minimal zen configuration in existing project (like shadcn/ui)"""
    import yaml
    
    # Create .zen directory
    zen_dir = Path(".zen")
    zen_dir.mkdir(exist_ok=True)
    
    # Create minimal config
    config = {
        "name": Path.cwd().name,
        "version": "1.0.0",
        "components": {}
    }
    
    config_path = zen_dir / "config.yaml"
    with open(config_path, "w") as f:
        yaml.dump(config, f, default_flow_style=False, indent=2)
    
    # Create or update .gitignore to include .zen/
    gitignore_path = Path(".gitignore")
    if gitignore_path.exists():
        with open(gitignore_path, "r") as f:
            content = f.read()
        if ".zen/" not in content:
            with open(gitignore_path, "a") as f:
                f.write("\n# zen\n.zen/\n")
    else:
        with open(gitignore_path, "w") as f:
            f.write("# zen\n.zen/\n")

def main():
    """Entry point for the CLI"""
    cli()

if __name__ == "__main__":
    main()
