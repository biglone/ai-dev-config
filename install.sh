#!/usr/bin/env bash

# AI Dev Config Installer
# Installs configuration for Claude Code, Cursor, and other AI dev tools

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
fi

print_info "Detected OS: $OS"
echo

# Get installation scope
SCOPE="user"
if [[ "$1" == "--project" ]]; then
    SCOPE="project"
    print_info "Installing in project scope"
elif [[ "$1" == "--local" ]]; then
    SCOPE="local"
    print_info "Installing in local scope"
else
    print_info "Installing in user scope (global)"
fi
echo

# Claude Code Configuration
install_claude_config() {
    print_info "Installing Claude Code configuration..."

    local claude_dir
    if [[ "$SCOPE" == "user" ]]; then
        claude_dir="$HOME/.claude"
    elif [[ "$SCOPE" == "project" ]]; then
        claude_dir=".claude"
    else
        claude_dir=".claude"
    fi

    # Create directory if it doesn't exist
    mkdir -p "$claude_dir"

    # Backup existing settings if present
    if [[ -f "$claude_dir/settings.json" ]]; then
        backup_file="$claude_dir/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$claude_dir/settings.json" "$backup_file"
        print_warning "Backed up existing settings to: $backup_file"
    fi

    # Copy settings
    cp "claude/settings.json" "$claude_dir/settings.json"
    print_success "Claude Code settings installed to: $claude_dir/settings.json"
}

# Cursor Configuration
install_cursor_config() {
    print_info "Installing Cursor configuration..."

    local cursor_dir
    if [[ "$OS" == "macos" ]]; then
        cursor_dir="$HOME/Library/Application Support/Cursor/User"
    elif [[ "$OS" == "linux" ]]; then
        cursor_dir="$HOME/.config/Cursor/User"
    elif [[ "$OS" == "windows" ]]; then
        cursor_dir="$APPDATA/Cursor/User"
    else
        print_warning "Unsupported OS for Cursor configuration"
        return
    fi

    if [[ ! -d "$cursor_dir" ]]; then
        print_warning "Cursor directory not found. Skipping Cursor configuration."
        return
    fi

    # Backup existing settings
    if [[ -f "$cursor_dir/settings.json" ]]; then
        backup_file="$cursor_dir/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$cursor_dir/settings.json" "$backup_file"
        print_warning "Backed up existing Cursor settings to: $backup_file"
    fi

    # Copy Cursor settings if they exist
    if [[ -f "cursor/settings.json" ]]; then
        cp "cursor/settings.json" "$cursor_dir/settings.json"
        print_success "Cursor settings installed to: $cursor_dir/settings.json"
    else
        print_warning "No Cursor settings found in ai-dev-config/cursor/"
    fi
}

# Main installation
main() {
    echo "╔════════════════════════════════════════════════╗"
    echo "║        AI Dev Config Installer v1.0.0         ║"
    echo "╚════════════════════════════════════════════════╝"
    echo

    install_claude_config
    echo

    # Ask if user wants to install Cursor config
    if [[ -f "cursor/settings.json" ]]; then
        read -p "Install Cursor configuration? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_cursor_config
            echo
        fi
    fi

    echo
    print_success "Installation complete!"
    echo
    print_info "To verify Claude Code settings:"
    if [[ "$SCOPE" == "user" ]]; then
        echo "  cat ~/.claude/settings.json"
    else
        echo "  cat .claude/settings.json"
    fi
    echo
    print_info "Usage:"
    echo "  claude              # Use with new settings"
    echo "  claude --help       # View all options"
    echo
}

# Run main installation
main
