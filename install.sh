#!/usr/bin/env bash

# AI Dev Config Installer
# Installs configuration for Claude Code, Cursor, and other AI dev tools
# Version 1.1.0 - Smart merge support

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

# Detect available JSON processor
detect_json_processor() {
    if command -v jq &> /dev/null; then
        echo "jq"
    elif command -v python3 &> /dev/null; then
        echo "python3"
    elif command -v python &> /dev/null; then
        echo "python"
    elif command -v node &> /dev/null; then
        echo "node"
    else
        echo "none"
    fi
}

# Merge JSON files intelligently
# $1: old config file path
# $2: new config file path
# $3: output file path
merge_json_configs() {
    local old_config="$1"
    local new_config="$2"
    local output_config="$3"
    local processor=$(detect_json_processor)

    if [[ "$processor" == "none" ]]; then
        print_warning "No JSON processor found (jq/python/node). Using simple copy instead of merge."
        cp "$new_config" "$output_config"
        return
    fi

    print_info "Using $processor for smart config merge..."

    case "$processor" in
        "jq")
            # Use jq to merge: preserve env and enabledPlugins from old, add permissions from new
            jq -s '.[0] * .[1]' "$old_config" "$new_config" > "$output_config"
            ;;
        "python3"|"python")
            # Use Python to merge configs
            $processor - "$old_config" "$new_config" "$output_config" <<'PYTHON_SCRIPT'
import json
import sys

old_file, new_file, output_file = sys.argv[1], sys.argv[2], sys.argv[3]

with open(old_file, 'r') as f:
    old_config = json.load(f)

with open(new_file, 'r') as f:
    new_config = json.load(f)

# Merge: keep env and enabledPlugins from old config
merged = new_config.copy()

if 'env' in old_config:
    merged['env'] = old_config['env']

if 'enabledPlugins' in old_config:
    merged['enabledPlugins'] = old_config['enabledPlugins']

# Preserve other top-level keys from old config if not in new config
for key in old_config:
    if key not in merged and key not in ['permissions', '$schema']:
        merged[key] = old_config[key]

with open(output_file, 'w') as f:
    json.dump(merged, f, indent=2)
PYTHON_SCRIPT
            ;;
        "node")
            # Use Node.js to merge configs
            node - "$old_config" "$new_config" "$output_config" <<'NODE_SCRIPT'
const fs = require('fs');
const [oldFile, newFile, outputFile] = process.argv.slice(2);

const oldConfig = JSON.parse(fs.readFileSync(oldFile, 'utf8'));
const newConfig = JSON.parse(fs.readFileSync(newFile, 'utf8'));

const merged = { ...newConfig };

if (oldConfig.env) {
    merged.env = oldConfig.env;
}

if (oldConfig.enabledPlugins) {
    merged.enabledPlugins = oldConfig.enabledPlugins;
}

// Preserve other top-level keys from old config
for (const key in oldConfig) {
    if (!merged.hasOwnProperty(key) && key !== 'permissions' && key !== '$schema') {
        merged[key] = oldConfig[key];
    }
}

fs.writeFileSync(outputFile, JSON.stringify(merged, null, 2));
NODE_SCRIPT
            ;;
    esac

    if [[ $? -eq 0 ]]; then
        print_success "Successfully merged configurations"

        # Show what was preserved
        if [[ -f "$old_config" ]]; then
            if grep -q '"env"' "$old_config" 2>/dev/null; then
                print_info "  → Preserved: environment variables"
            fi
            if grep -q '"enabledPlugins"' "$old_config" 2>/dev/null; then
                print_info "  → Preserved: enabled plugins"
            fi
        fi
        print_info "  → Added: fine-grained permissions"
    else
        print_error "Merge failed, falling back to simple copy"
        cp "$new_config" "$output_config"
    fi
}

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
FORCE_OVERWRITE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            SCOPE="project"
            shift
            ;;
        --local)
            SCOPE="local"
            shift
            ;;
        --force)
            FORCE_OVERWRITE=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Usage: $0 [--project|--local] [--force]"
            exit 1
            ;;
    esac
done

if [[ "$SCOPE" == "project" ]]; then
    print_info "Installing in project scope"
elif [[ "$SCOPE" == "local" ]]; then
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

    local settings_file="$claude_dir/settings.json"
    local new_settings="claude/settings.json"

    # Check if existing settings exist
    if [[ -f "$settings_file" ]]; then
        # Backup existing settings
        backup_file="$settings_file.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$settings_file" "$backup_file"
        print_warning "Backed up existing settings to: $backup_file"

        # Smart merge or force overwrite
        if [[ "$FORCE_OVERWRITE" == true ]]; then
            print_warning "Force overwrite enabled, skipping merge"
            cp "$new_settings" "$settings_file"
        else
            # Create temp file for merge
            temp_merged=$(mktemp)
            merge_json_configs "$settings_file" "$new_settings" "$temp_merged"
            mv "$temp_merged" "$settings_file"
        fi
    else
        # No existing config, just copy
        cp "$new_settings" "$settings_file"
        print_info "Created new configuration file"
    fi

    print_success "Claude Code settings installed to: $settings_file"
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
    echo "║      AI Dev Config Installer v1.1.0           ║"
    echo "║      Smart merge · Preserve your settings     ║"
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
    print_info "Installation options:"
    echo "  --project           # Install in project scope (.claude/)"
    echo "  --local             # Install in local scope (.claude/settings.local.json)"
    echo "  --force             # Force overwrite without merging"
    echo
}

# Run main installation
main
