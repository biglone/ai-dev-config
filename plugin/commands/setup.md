---
description: Quick setup command to install AI dev config on current machine
---

# Setup AI Dev Config

This command helps you quickly install the AI development configuration on your current machine.

## Instructions for Claude

When the user runs this command:

1. **Detect the current environment:**
   - Check if we're in a project directory or user's home directory
   - Identify the operating system (macOS, Linux, Windows)

2. **Ask for installation scope:**
   - User scope (global, applies to all projects)
   - Project scope (applies to current project only)
   - Local scope (project-specific, gitignored)

3. **Run the appropriate installer:**
   - For macOS/Linux: Execute `./install.sh` with the chosen scope
   - For Windows: Execute `.\install.ps1` with the chosen scope

4. **Verify installation:**
   - Check that settings files were created in the correct locations
   - Display the installation summary

5. **Provide next steps:**
   - Show how to verify the configuration
   - Suggest testing with a simple Claude Code command

## Example Usage

User: `/setup`

Claude should:
- Detect OS and current directory
- Ask which scope to install in
- Run the installer
- Confirm successful installation
- Show verification commands
