# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-04

### Added
- Initial release of AI Dev Config
- Claude Code fine-grained permissions configuration
- Cursor IDE optimized settings
- Cross-platform installation scripts (bash and PowerShell)
- Claude Code plugin with `/setup` command
- Post-edit hooks for code quality reminders
- Support for user, project, and local scopes
- Comprehensive README documentation
- Security-first permission model
- Sensitive file protection (.env, keys, secrets)

### Security
- Automatic blocking of sensitive files
- Explicit confirmation for destructive operations
- Deny rules for dangerous commands (rm -rf, sudo)

[1.0.0]: https://github.com/biglone/ai-dev-config/releases/tag/v1.0.0
