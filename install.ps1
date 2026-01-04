# AI Dev Config Installer for Windows PowerShell
# Installs configuration for Claude Code, Cursor, and other AI dev tools

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("user", "project", "local")]
    [string]$Scope = "user"
)

# Helper functions
function Print-Info { Write-Host "ℹ $args" -ForegroundColor Blue }
function Print-Success { Write-Host "✓ $args" -ForegroundColor Green }
function Print-Warning { Write-Host "⚠ $args" -ForegroundColor Yellow }
function Print-Error { Write-Host "✗ $args" -ForegroundColor Red }

# Claude Code Configuration
function Install-ClaudeConfig {
    Print-Info "Installing Claude Code configuration..."

    $claudeDir = if ($Scope -eq "user") {
        "$env:USERPROFILE\.claude"
    } else {
        ".claude"
    }

    # Create directory if it doesn't exist
    if (-not (Test-Path $claudeDir)) {
        New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    }

    # Backup existing settings
    $settingsPath = Join-Path $claudeDir "settings.json"
    if (Test-Path $settingsPath) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = "$settingsPath.backup.$timestamp"
        Copy-Item $settingsPath $backupPath
        Print-Warning "Backed up existing settings to: $backupPath"
    }

    # Copy settings
    Copy-Item "claude\settings.json" $settingsPath -Force
    Print-Success "Claude Code settings installed to: $settingsPath"
}

# Cursor Configuration
function Install-CursorConfig {
    Print-Info "Installing Cursor configuration..."

    $cursorDir = "$env:APPDATA\Cursor\User"

    if (-not (Test-Path $cursorDir)) {
        Print-Warning "Cursor directory not found. Skipping Cursor configuration."
        return
    }

    # Backup existing settings
    $settingsPath = Join-Path $cursorDir "settings.json"
    if (Test-Path $settingsPath) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = "$settingsPath.backup.$timestamp"
        Copy-Item $settingsPath $backupPath
        Print-Warning "Backed up existing Cursor settings to: $backupPath"
    }

    # Copy Cursor settings if they exist
    if (Test-Path "cursor\settings.json") {
        Copy-Item "cursor\settings.json" $settingsPath -Force
        Print-Success "Cursor settings installed to: $settingsPath"
    } else {
        Print-Warning "No Cursor settings found in ai-dev-config\cursor\"
    }
}

# Main installation
function Main {
    Write-Host "╔════════════════════════════════════════════════╗"
    Write-Host "║        AI Dev Config Installer v1.0.0         ║"
    Write-Host "╚════════════════════════════════════════════════╝"
    Write-Host ""

    Print-Info "Installation scope: $Scope"
    Write-Host ""

    Install-ClaudeConfig
    Write-Host ""

    # Ask if user wants to install Cursor config
    if (Test-Path "cursor\settings.json") {
        $response = Read-Host "Install Cursor configuration? (y/N)"
        if ($response -match "^[Yy]$") {
            Install-CursorConfig
            Write-Host ""
        }
    }

    Write-Host ""
    Print-Success "Installation complete!"
    Write-Host ""
    Print-Info "To verify Claude Code settings:"
    if ($Scope -eq "user") {
        Write-Host "  Get-Content $env:USERPROFILE\.claude\settings.json"
    } else {
        Write-Host "  Get-Content .claude\settings.json"
    }
    Write-Host ""
    Print-Info "Usage:"
    Write-Host "  claude              # Use with new settings"
    Write-Host "  claude --help       # View all options"
    Write-Host ""
}

# Run main installation
Main
