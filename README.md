# AI Dev Config

> Personal configuration for AI-powered development tools (Claude Code, Codex CLI, Cursor, and more)

This repository contains configuration files and automation scripts for AI development tools, designed to be easily shareable across different machines and teams.

## 🚀 Quick Start

### One-Line Installation (Recommended)

**Simple Mode - Workspace Full Permissions:**
```bash
curl -fsSL https://raw.githubusercontent.com/biglone/ai-dev-config/main/install-remote.sh | bash -s -- --simple
```

**Fine-grained Mode:**
```bash
curl -fsSL https://raw.githubusercontent.com/biglone/ai-dev-config/main/install-remote.sh | bash
```

### Manual Installation

```bash
git clone https://github.com/biglone/ai-dev-config.git
cd ai-dev-config

./install.sh --simple  # Workspace full permissions (recommended)
./install.sh           # Fine-grained permissions
```

## ✅ Verify Installation

After installation, restart your CLI tool and verify:

**Claude Code:**
```bash
# Check config
cat ~/.claude/settings.json

# In Claude Code session
/permissions
```

**Codex CLI:**
```bash
# Check config
cat ~/.codex/config.toml

# In Codex session
/config
```

## 📦 What's Included

### Claude Code

| Mode | Flag | Description |
|------|------|-------------|
| Simple | `--simple` | All operations allowed, no prompts |
| Fine-grained | (default) | Selective permissions with safety rules |

**Simple Mode** (`claude/settings-simple.json`):
```json
{
  "permissions": {
    "allow": ["Bash", "Read", "Edit", "Write", "Glob", "Grep", "TodoWrite", "Task", "WebFetch", "WebSearch"]
  }
}
```

**Fine-grained Mode** (`claude/settings.json`):
- Auto-allow: File operations, package managers, safe git commands
- Ask: Dangerous git ops (push/pull/merge), rm/mv/cp, network
- Deny: .env, *.pem, *.key, secrets/**, rm -rf, sudo

### Codex CLI

**Simple Mode** (`codex/config-simple.toml`):
```toml
approval_policy = "never"
sandbox_mode = "danger-full-access"
network_access = "enabled"
hide_full_access_warning = true
```

- All operations allowed without approval
- Full sandbox access
- Network access enabled

### Cursor

Optimized settings in `cursor/settings.json`:
- Auto-formatting with Prettier
- ESLint auto-fix on save
- Smart file exclusions

## 📖 Installation Options

| Flag | Description |
|------|-------------|
| `--simple` | Workspace full permissions |
| `--project` | Install to `.claude/` in current directory |
| `--local` | Install to `.claude/settings.local.json` |
| `--force` | Overwrite without merging |

**Examples:**
```bash
./install.sh --simple              # User scope, full permissions
./install.sh --simple --project    # Project scope, full permissions
./install.sh --force               # Force overwrite
```

**Configuration Locations:**
| Scope | Claude Code | Codex CLI |
|-------|-------------|-----------|
| User | `~/.claude/settings.json` | `~/.codex/config.toml` |
| Project | `.claude/settings.json` | N/A |

## ✨ Features

- **Smart Merge**: Preserves existing env, plugins, and custom settings
- **Auto Backup**: Creates timestamped backups before changes
- **Multi-tool Support**: Claude Code + Codex CLI + Cursor
- **Cross-platform**: Works on macOS, Linux, Windows

## 📂 Repository Structure

```
ai-dev-config/
├── claude/
│   ├── settings.json          # Fine-grained permissions
│   └── settings-simple.json   # Simple mode (full permissions)
├── codex/
│   └── config-simple.toml     # Codex CLI config
├── cursor/
│   └── settings.json          # Cursor IDE config
├── plugin/                    # Claude Code plugin
├── install.sh                 # Unix installer
├── install-remote.sh          # Remote installer
└── install.ps1                # Windows installer
```

## 🔄 Updating

```bash
# Remote update
curl -fsSL https://raw.githubusercontent.com/biglone/ai-dev-config/main/install-remote.sh | bash -s -- --simple

# Local update
cd ai-dev-config && git pull && ./install.sh --simple
```

## 🔐 Security Notes

**Simple Mode** - Use in trusted environments only:
- Personal projects
- Local development
- Trusted codebases

**Fine-grained Mode** - Recommended for:
- Shared/team projects
- Production environments
- Untrusted codebases

## 🐛 Troubleshooting

**Config not working?**
```bash
# Restart the CLI tool after installation
exit
claude  # or codex
```

**Permission still requested?**
```bash
# Check if config loaded correctly
cat ~/.claude/settings.json
cat ~/.codex/config.toml
```

## 📝 License

MIT License - see [LICENSE](LICENSE) for details

## 🔗 Links

- [Claude Code](https://claude.ai/code) - Anthropic's CLI
- [Codex CLI](https://github.com/openai/codex) - OpenAI's CLI
- [Cursor](https://cursor.sh) - AI-first editor
