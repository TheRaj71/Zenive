"""
Logging configuration for Zenive with beautiful animations.
"""

import logging
import sys
import time
from typing import Optional, Any
from contextlib import contextmanager
from rich.console import Console
from rich.logging import RichHandler
from rich.text import Text
from rich.spinner import Spinner
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn
from rich.panel import Panel
from rich.align import Align


class ZeniveLogger:
    """Custom logger for Zenive with rich formatting and animations."""
    
    def __init__(self, name: str = "zenive", level: int = logging.INFO):
        self.console = Console()
        self.logger = logging.getLogger(name)
        self.logger.setLevel(level)
        
        # Remove existing handlers to avoid duplicates
        for handler in self.logger.handlers[:]:
            self.logger.removeHandler(handler)
        
        # Create rich handler
        rich_handler = RichHandler(
            console=self.console,
            show_time=False,
            show_path=False,
            markup=True,
        )
        rich_handler.setLevel(level)
        
        # Create formatter
        formatter = logging.Formatter("%(message)s")
        rich_handler.setFormatter(formatter)
        
        self.logger.addHandler(rich_handler)
        self.logger.propagate = False
        
        # Animation state
        self._current_spinner = None
    
    def info(self, message: str, **kwargs):
        """Log info message with rich formatting."""
        self.logger.info(f"[blue]ℹ[/blue] {message}", **kwargs)
    
    def success(self, message: str, **kwargs):
        """Log success message with rich formatting."""
        self.logger.info(f"[green]✓[/green] {message}", **kwargs)
    
    def warning(self, message: str, **kwargs):
        """Log warning message with rich formatting."""
        self.logger.warning(f"[yellow]⚠[/yellow] {message}", **kwargs)
    
    def error(self, message: str, **kwargs):
        """Log error message with rich formatting."""
        self.logger.error(f"[red]✗[/red] {message}", **kwargs)
    
    def debug(self, message: str, **kwargs):
        """Log debug message with rich formatting."""
        self.logger.debug(f"[dim]🐛[/dim] {message}", **kwargs)
    
    def step(self, message: str, **kwargs):
        """Log step message for processes."""
        self.logger.info(f"[cyan]→[/cyan] {message}", **kwargs)
    
    def progress(self, message: str, **kwargs):
        """Log progress message."""
        self.logger.info(f"[magenta]⟳[/magenta] {message}", **kwargs)
    
    @contextmanager
    def spinner(self, message: str, spinner_style: str = "dots"):
        """Context manager for showing a spinner during operations."""
        with self.console.status(f"[cyan]{message}[/cyan]", spinner=spinner_style) as status:
            try:
                yield status
            except Exception as e:
                self.error(f"Failed: {e}")
                raise
    
    def show_banner(self, title: str, subtitle: str = None):
        """Show a beautiful banner."""
        content = f"[bold cyan]{title}[/bold cyan]"
        if subtitle:
            content += f"\n[dim]{subtitle}[/dim]"
        
        panel = Panel(
            Align.center(content),
            border_style="cyan",
            padding=(1, 2)
        )
        self.console.print(panel)
    
    def show_component_info(self, name: str, version: str, description: str, 
                          category: str, dependencies: list, files_count: int):
        """Show component information in a beautiful format."""
        info_text = f"""[bold green]{name}[/bold green] [dim]v{version}[/dim]
[dim]{description}[/dim]

[yellow]Category:[/yellow] {category}
[yellow]Files:[/yellow] {files_count} files
[yellow]Dependencies:[/yellow] {', '.join(dependencies) if dependencies else 'None'}"""
        
        panel = Panel(
            info_text,
            title="📦 Component Info",
            border_style="green",
            padding=(1, 2)
        )
        self.console.print(panel)
    
    def show_success_summary(self, component: str, files_installed: int, 
                           dependencies_added: int, install_path: str):
        """Show installation success summary."""
        summary = f"""[bold green]✨ Successfully installed {component}[/bold green]

[cyan]📁 Files installed:[/cyan] {files_installed}
[cyan]📦 Dependencies added:[/cyan] {dependencies_added}
[cyan]📍 Install path:[/cyan] {install_path}

[dim]🎉 Component is ready to use![/dim]"""
        
        if dependencies_added > 0:
            summary += "\n[dim]💡 Run 'pip install -r requirements.txt' to install new dependencies[/dim]"
        
        panel = Panel(
            summary,
            border_style="green",
            padding=(1, 2)
        )
        self.console.print(panel)
    
    def animate_text(self, text: str, delay: float = 0.05):
        """Animate text character by character."""
        for char in text:
            self.console.print(char, end="")
            time.sleep(delay)
        self.console.print()  # New line at the end


# Global logger instance
_logger: Optional[ZeniveLogger] = None


def get_logger(name: str = "zenive", level: int = logging.INFO) -> ZeniveLogger:
    """Get or create the global Zenive logger."""
    global _logger
    if _logger is None:
        _logger = ZeniveLogger(name, level)
    return _logger


def set_log_level(level: int):
    """Set the logging level for the global logger."""
    logger = get_logger()
    logger.logger.setLevel(level)
    for handler in logger.logger.handlers:
        handler.setLevel(level)


def enable_debug():
    """Enable debug logging."""
    set_log_level(logging.DEBUG)


def disable_debug():
    """Disable debug logging."""
    set_log_level(logging.INFO)

def setup_logging(verbose: bool = False):
    """Setup logging configuration."""
    level = logging.DEBUG if verbose else logging.INFO
    set_log_level(level)
