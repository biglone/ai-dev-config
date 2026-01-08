#!/usr/bin/env bash

# AI Dev Config Remote Installer
# Downloads and installs configuration from GitHub
# Version 1.2.0

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

# Configuration
REPO_URL="https://github.com/biglone/ai-dev-config.git"
TEMP_DIR="/tmp/ai-dev-config-install-$$"
INSTALL_SCOPE="user"
FORCE_OVERWRITE=false
SIMPLE_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            INSTALL_SCOPE="project"
            shift
            ;;
        --local)
            INSTALL_SCOPE="local"
            shift
            ;;
        --force)
            FORCE_OVERWRITE=true
            shift
            ;;
        --simple)
            SIMPLE_MODE=true
            shift
            ;;
        -h|--help)
            echo "AI Dev Config Remote Installer"
            echo ""
            echo "Usage: curl -fsSL https://raw.githubusercontent.com/biglone/ai-dev-config/main/install-remote.sh | bash"
            echo "       curl -fsSL https://raw.githubusercontent.com/biglone/ai-dev-config/main/install-remote.sh | bash -s -- [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --project    Install in project scope (.claude/)"
            echo "  --local      Install in local scope (.claude/settings.local.json)"
            echo "  --force      Force overwrite without merging"
            echo "  --simple     Use simple mode (workspace full permissions)"
            echo "  -h, --help   Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Cleanup function
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        print_info "Cleaned up temporary files"
    fi
}

trap cleanup EXIT

main() {
    echo "╔════════════════════════════════════════════════╗"
    echo "║   AI Dev Config Remote Installer v1.2.0       ║"
    echo "║   Simple mode · Workspace full permissions    ║"
    echo "╚════════════════════════════════════════════════╝"
    echo

    # Check for git
    if ! command -v git &> /dev/null; then
        print_error "Git is required but not installed."
        echo "Please install Git and try again."
        exit 1
    fi

    # Create temporary directory
    print_info "Creating temporary directory..."
    mkdir -p "$TEMP_DIR"

    # Clone repository
    print_info "Downloading configuration from GitHub..."
    if ! git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR" 2>&1; then
        print_error "Failed to clone repository"
        exit 1
    fi
    print_success "Configuration downloaded"

    # Navigate to temp directory
    cd "$TEMP_DIR"

    # Build install command
    INSTALL_CMD="./install.sh"
    if [[ "$INSTALL_SCOPE" == "project" ]]; then
        INSTALL_CMD="$INSTALL_CMD --project"
    elif [[ "$INSTALL_SCOPE" == "local" ]]; then
        INSTALL_CMD="$INSTALL_CMD --local"
    fi
    if [[ "$FORCE_OVERWRITE" == true ]]; then
        INSTALL_CMD="$INSTALL_CMD --force"
    fi
    if [[ "$SIMPLE_MODE" == true ]]; then
        INSTALL_CMD="$INSTALL_CMD --simple"
    fi

    # Run installation
    echo
    print_info "Running installation script..."
    echo
    bash -c "$INSTALL_CMD"

    echo
    print_success "Remote installation complete!"
    echo
    print_info "Repository cloned to temporary location and will be cleaned up automatically."
    print_info "To keep a local copy of the repository, run:"
    echo "  git clone $REPO_URL"
    echo
}

main "$@"
