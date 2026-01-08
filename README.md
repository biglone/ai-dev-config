# AI Dev Config

> Personal configuration for AI-powered development tools (Claude Code, Codex CLI, Cursor, and more)

This repository contains my personal configuration files and automation scripts for AI development tools, designed to be easily shareable across different machines and teams.

## 🚀 Quick Start

### Option 1: One-Line Installation (Recommended)

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/biglone/ai-dev-config/main/install-remote.sh | bash
```

With options:
```bash
# Install in project scope
curl -fsSL https://raw.githubusercontent.com/biglone/ai-dev-config/main/install-remote.sh | bash -s -- --project

# Force overwrite without merging
curl -fsSL https://raw.githubusercontent.com/biglone/ai-dev-config/main/install-remote.sh | bash -s -- --force
```

**Windows (PowerShell):**
```powershell
# Note: Remote installation for Windows is not yet supported via one-liner
# Please use Option 2 (Manual Installation) instead
iwr -useb https://github.com/biglone/ai-dev-config/archive/refs/heads/main.zip -OutFile ai-dev-config.zip
Expand-Archive ai-dev-config.zip -DestinationPath .
cd ai-dev-config-main
.\install.ps1
```

### Option 2: Manual Installation

```bash
# Clone the repository
git clone https://github.com/biglone/ai-dev-config.git
cd ai-dev-config

# Run installer
./install.sh           # macOS/Linux (fine-grained permissions)
./install.sh --simple  # macOS/Linux (workspace full permissions)
.\install.ps1          # Windows PowerShell
```

### Option 3: Install as Claude Code Plugin

```bash
# Add the plugin marketplace
claude plugin marketplace add biglone/ai-dev-config

# Install the plugin
claude plugin install ai-dev-config@biglone-ai-config
```

## ✨ Smart Configuration Merge

**Version 1.1.0** introduces intelligent configuration merging:

- **Preserves your existing settings**: Environment variables, enabled plugins, and custom configurations are automatically retained
- **Adds new permissions**: Fine-grained permission controls are merged into your existing config
- **Automatic backups**: Every installation creates a timestamped backup of your current settings
- **Multiple JSON processors**: Works with jq, Python, Node.js, or PowerShell (depending on what's available)
- **Force overwrite option**: Use `--force` flag to skip merging and do a clean install

**Example merge behavior:**
```bash
# Before: Your existing settings
{
  "env": { ... },
  "enabledPlugins": { ... }
}

# After: Merged with new permissions
{
  "$schema": "...",
  "env": { ... },              # ← Preserved
  "enabledPlugins": { ... },   # ← Preserved
  "permissions": { ... }       # ← Added
}
```

## 📦 What's Included

### Claude Code Configuration

Two permission modes available:

#### Simple Mode (`--simple`) - Recommended for trusted projects

Minimal configuration with workspace full permissions (`claude/settings-simple.json`):

```json
{
  "permissions": {
    "allow": ["Bash", "Read", "Edit", "Write", "Glob", "Grep", "TodoWrite", "Task", "WebFetch", "WebSearch"]
  }
}
```

- All operations allowed in current workspace
- No confirmation prompts
- Best for personal projects and trusted environments

#### Fine-grained Mode (default)

Fine-grained permission controls in `claude/settings.json`:

- **Auto-allowed operations:**
  - File operations: Read, Edit, Write, Glob, Grep
  - Package managers: npm, pnpm, yarn, bun
  - Safe git commands: status, diff, log, branch, checkout, add, commit
  - Development tools: node, python
  - File system navigation: ls, pwd, cd, mkdir

- **Ask before executing:**
  - Dangerous git operations: push, pull, fetch, merge, rebase
  - File modifications: rm, mv, cp
  - Network operations: WebFetch, WebSearch

- **Explicitly denied:**
  - Sensitive files: .env, *.pem, *.key, secrets/**
  - Dangerous commands: rm -rf, sudo

### Codex CLI Configuration

Simple mode configuration in `codex/config-simple.toml`:

```toml
approval_policy = "never"
sandbox_mode = "danger-full-access"
network_access = "enabled"
hide_full_access_warning = true
```

- All operations allowed without approval
- Full sandbox access (no restrictions)
- Network access enabled
- Best for trusted development environments

### Cursor Configuration

Optimized settings in `cursor/settings.json`:

- Auto-formatting on save with Prettier
- ESLint auto-fix on save
- Import organization
- Claude 3.5 Sonnet as default model
- Smart file exclusions for better performance

### Plugin Features

Custom Claude Code plugin with:

- `/setup` command for quick installation
- Post-edit hooks for code quality reminders
- Extensible command and agent system

## 📖 Installation Scopes

### User Scope (Default)

Applies configuration globally to all projects on your machine.

```bash
./install.sh           # Default scope (fine-grained, smart merge)
./install.sh --simple  # Simple mode (workspace full permissions)
./install.sh --force   # Force overwrite without merging
```

Configuration location:
- **macOS/Linux:** `~/.claude/settings.json`
- **Windows:** `%USERPROFILE%\.claude\settings.json`

### Project Scope

Shares configuration with your team via git.

```bash
./install.sh --project
```

Configuration location: `.claude/settings.json` in your project root

### Local Scope

Project-specific configuration that won't be committed to git.

```bash
./install.sh --local
```

Configuration location: `.claude/settings.local.json` in your project root

## 🛠️ Customization

### Modifying Claude Code Permissions

Edit `claude/settings.json` to customize permissions:

```json
{
  "permissions": {
    "allow": [
      "YourCustomTool",
      "Bash(your-command *)"
    ],
    "ask": [
      "Bash(risky-command *)"
    ],
    "deny": [
      "Read(sensitive-file.txt)"
    ]
  }
}
```

### Adding Custom Commands

Create new commands in `plugin/commands/`:

```markdown
---
description: Your command description
---

# Your Command

Instructions for Claude on how to execute this command.
```

### Adding Hooks

Extend `plugin/hooks/hooks.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "your-custom-script.sh"
          }
        ]
      }
    ]
  }
}
```

## 📂 Repository Structure

```
ai-dev-config/
├── claude/
│   ├── settings.json          # Claude Code configuration (fine-grained)
│   └── settings-simple.json   # Claude Code configuration (simple mode)
├── codex/
│   └── config-simple.toml     # Codex CLI configuration (simple mode)
├── cursor/
│   └── settings.json          # Cursor IDE configuration
├── plugin/
│   ├── .claude-plugin/
│   │   ├── plugin.json        # Plugin manifest
│   │   └── marketplace.json   # Marketplace definition
│   ├── commands/              # Custom slash commands
│   │   └── setup.md
│   └── hooks/                 # Event hooks
│       └── hooks.json
├── install.sh                 # Unix installer
├── install.ps1                # Windows installer
├── .gitignore
├── LICENSE
└── README.md
```

## 🔄 Updating Configuration

### Update via One-Line Command (Easiest)

```bash
curl -fsSL https://raw.githubusercontent.com/biglone/ai-dev-config/main/install-remote.sh | bash
```

The remote installer automatically downloads the latest version and merges with your existing settings.

### Update Local Copy

```bash
cd ai-dev-config
git pull origin main
./install.sh
```

### Update Plugin

```bash
claude plugin update ai-dev-config@biglone-ai-config
```

## 🤝 Sharing with Your Team

### Method 1: One-Line Installation (Easiest)

Share this command with your team for project-wide configuration:

```bash
curl -fsSL https://raw.githubusercontent.com/biglone/ai-dev-config/main/install-remote.sh | bash -s -- --project
```

### Method 2: Clone and Install

Share the repository URL with your team:

```bash
git clone https://github.com/biglone/ai-dev-config.git
cd ai-dev-config
./install.sh --project
```

### Method 2: Plugin Marketplace

Team members can install via Claude Code plugin system:

```bash
claude plugin marketplace add biglone/ai-dev-config
claude plugin install ai-dev-config@biglone-ai-config
```

### Method 3: Project-Level Configuration

Commit `.claude/settings.json` to your project repository for automatic team-wide configuration.

## 🔐 Security Considerations

This configuration implements defense-in-depth security:

1. **Sensitive file protection:** Automatically blocks access to .env, keys, and secrets
2. **Explicit confirmations:** Requires approval for destructive operations
3. **Audit trail:** All permissions are explicitly declared and version-controlled
4. **Scope isolation:** User/project/local scopes prevent unintended permission escalation

## 🐛 Troubleshooting

### Configuration not taking effect

```bash
# Verify installation location
cat ~/.claude/settings.json      # User scope
cat .claude/settings.json        # Project scope

# Restart Claude Code
claude --version
```

### Permission still being requested

Check the permission pattern in `claude/settings.json`. Patterns support wildcards:

```json
{
  "allow": [
    "Bash(npm *)",           # Matches all npm commands
    "Read(src/**/*.ts)"      # Matches TypeScript files in src/
  ]
}
```

### Plugin not loading

```bash
# List installed plugins
claude plugin list

# Reinstall plugin
claude plugin uninstall ai-dev-config@biglone-ai-config
claude plugin install ai-dev-config@biglone-ai-config
```

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

- [Claude Code](https://claude.com/code) - Anthropic's official CLI tool
- [Cursor](https://cursor.sh) - AI-first code editor

## 📮 Feedback

Issues and pull requests are welcome! Feel free to customize this configuration for your own workflow.

---

**Note:** Remember to update your GitHub username and email in:
- `plugin/.claude-plugin/plugin.json`
- `plugin/.claude-plugin/marketplace.json`
- Installation URLs in this README
