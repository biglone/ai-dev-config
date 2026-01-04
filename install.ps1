# AI Dev Config Installer for Windows PowerShell
# Installs configuration for Claude Code, Cursor, and other AI dev tools
# Version 1.1.0 - Smart merge support

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("user", "project", "local")]
    [string]$Scope = "user",

    [Parameter(Mandatory=$false)]
    [switch]$Force = $false
)

# Helper functions
function Print-Info { Write-Host "ℹ $args" -ForegroundColor Blue }
function Print-Success { Write-Host "✓ $args" -ForegroundColor Green }
function Print-Warning { Write-Host "⚠ $args" -ForegroundColor Yellow }
function Print-Error { Write-Host "✗ $args" -ForegroundColor Red }

# Merge JSON configurations intelligently
function Merge-JsonConfigs {
    param(
        [string]$OldConfigPath,
        [string]$NewConfigPath,
        [string]$OutputPath
    )

    try {
        Print-Info "Using PowerShell for smart config merge..."

        $oldConfig = Get-Content $OldConfigPath -Raw | ConvertFrom-Json
        $newConfig = Get-Content $NewConfigPath -Raw | ConvertFrom-Json

        # Create merged config starting with new config
        $merged = $newConfig | ConvertTo-Json -Depth 100 | ConvertFrom-Json

        # Preserve env from old config
        if ($oldConfig.PSObject.Properties.Name -contains 'env') {
            $merged | Add-Member -NotePropertyName 'env' -NotePropertyValue $oldConfig.env -Force
            Print-Info "  → Preserved: environment variables"
        }

        # Preserve enabledPlugins from old config
        if ($oldConfig.PSObject.Properties.Name -contains 'enabledPlugins') {
            $merged | Add-Member -NotePropertyName 'enabledPlugins' -NotePropertyValue $oldConfig.enabledPlugins -Force
            Print-Info "  → Preserved: enabled plugins"
        }

        # Preserve other top-level keys (except permissions and $schema)
        $excludeKeys = @('permissions', '$schema')
        foreach ($prop in $oldConfig.PSObject.Properties) {
            if ($excludeKeys -notcontains $prop.Name -and
                $merged.PSObject.Properties.Name -notcontains $prop.Name) {
                $merged | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
            }
        }

        Print-Info "  → Added: fine-grained permissions"

        # Save merged config
        $merged | ConvertTo-Json -Depth 100 | Set-Content $OutputPath
        Print-Success "Successfully merged configurations"
        return $true
    }
    catch {
        Print-Error "Merge failed: $_"
        Print-Warning "Falling back to simple copy"
        Copy-Item $NewConfigPath $OutputPath -Force
        return $false
    }
}

# Claude Code Configuration
function Install-ClaudeConfig {
    Print-Info "Installing Claude Code configuration..."

    $claudeDir = switch ($Scope) {
        "user"    { "$env:USERPROFILE\.claude" }
        "project" { ".claude" }
        "local"   { ".claude" }
    }

    # Create directory if it doesn't exist
    if (-not (Test-Path $claudeDir)) {
        New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    }

    $settingsPath = Join-Path $claudeDir "settings.json"
    $newSettingsPath = "claude\settings.json"

    # Check if existing settings exist
    if (Test-Path $settingsPath) {
        # Backup existing settings
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = "$settingsPath.backup.$timestamp"
        Copy-Item $settingsPath $backupPath
        Print-Warning "Backed up existing settings to: $backupPath"

        # Smart merge or force overwrite
        if ($Force) {
            Print-Warning "Force overwrite enabled, skipping merge"
            Copy-Item $newSettingsPath $settingsPath -Force
        }
        else {
            # Create temp file for merge
            $tempFile = [System.IO.Path]::GetTempFileName()
            Merge-JsonConfigs -OldConfigPath $settingsPath -NewConfigPath $newSettingsPath -OutputPath $tempFile
            Move-Item $tempFile $settingsPath -Force
        }
    }
    else {
        # No existing config, just copy
        Copy-Item $newSettingsPath $settingsPath -Force
        Print-Info "Created new configuration file"
    }

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
    }
    else {
        Print-Warning "No Cursor settings found in ai-dev-config\cursor\"
    }
}

# Main installation
function Main {
    Write-Host "╔════════════════════════════════════════════════╗"
    Write-Host "║      AI Dev Config Installer v1.1.0           ║"
    Write-Host "║      Smart merge · Preserve your settings     ║"
    Write-Host "╚════════════════════════════════════════════════╝"
    Write-Host ""

    Print-Info "Installation scope: $Scope"
    if ($Force) {
        Print-Warning "Force overwrite mode enabled"
    }
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
    }
    else {
        Write-Host "  Get-Content .claude\settings.json"
    }
    Write-Host ""
    Print-Info "Usage:"
    Write-Host "  claude              # Use with new settings"
    Write-Host "  claude --help       # View all options"
    Write-Host ""
    Print-Info "Installation options:"
    Write-Host "  -Scope project      # Install in project scope (.claude/)"
    Write-Host "  -Scope local        # Install in local scope (.claude/settings.local.json)"
    Write-Host "  -Force              # Force overwrite without merging"
    Write-Host ""
}

# Run main installation
Main
