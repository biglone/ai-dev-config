# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-01-04

### Added
- **Smart configuration merge**: Installation scripts now intelligently merge new permissions with existing settings
  - Automatically preserves environment variables (`env`)
  - Automatically preserves enabled plugins (`enabledPlugins`)
  - Automatically preserves other custom configuration keys
  - Works with jq, Python, Node.js, or PowerShell (auto-detected)
- `--force` flag for installation scripts to skip merging and force overwrite
- Improved installation output showing what was preserved and what was added
- Enhanced error handling with graceful fallback to simple copy if merge fails

### Changed
- Updated installer version to v1.1.0
- Improved installation script banner to highlight smart merge feature
- Enhanced backup file naming consistency across platforms

### Fixed
- Installation no longer overwrites existing environment variables
- Plugin configurations are now preserved during updates
- Better handling of edge cases in JSON merging

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

[1.1.0]: https://github.com/biglone/ai-dev-config/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/biglone/ai-dev-config/releases/tag/v1.0.0
