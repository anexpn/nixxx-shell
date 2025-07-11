# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Nix flake that provides modular shell configuration for development environments. It uses Home Manager modules to configure shells (Zsh, Nushell) and development tools in a cross-platform way.

## Architecture

The project follows a modular structure with Home Manager modules:

- `flake.nix` - Main flake definition with cross-platform support
- `homeManagerModules/` - Contains all Home Manager modules
  - `shell/default.nix` - Imports all shell-related modules
  - `shell/zsh.nix` - Extended Zsh configuration with Oh My Zsh
  - `shell/nushell.nix` - Extended Nushell with git aliases and custom functions
  - `shell/tools.nix` - Collection of modern CLI tools and programs
  - `shell/nb.nix` - Note-taking tools and utilities

## Key Commands

### Testing Configuration Changes
```bash
# Build and test the flake
nix flake check

# Show flake info
nix flake show
```

### Development Workflow
```bash
# Update flake inputs
nix flake update

# Build specific output
nix build .#homeManagerModules.default

# Check syntax of Nix files
nix-instantiate --parse <file.nix>
```

## Module Structure

Each module follows the standard Home Manager pattern:
- `options` - Define configuration options with `mkEnableOption`
- `config` - Implementation using `mkIf` for conditional configuration

The modules are designed to be composable - users can enable specific components:
- `programs.zsh.extended.enable` - Enhanced Zsh with Oh My Zsh
- `programs.nushell.extended.enable` - Nushell with git aliases
- `shell.tools.enable` - Modern CLI tools collection
- `shell.nb.enable` - Note-taking toolkit

## Configuration Patterns

- Use `mkEnableOption` for boolean options
- Use `mkIf cfg.enable` for conditional configuration
- Support both vanilla and extended configurations where applicable
- Include local configuration file support (`.zshrc.local`, `.zshenv.local`)

## Cross-Platform Support

The flake supports multiple platforms via the `systems` attribute:
- x86_64-linux, aarch64-linux
- x86_64-darwin, aarch64-darwin (macOS)

## Tools and Programs

Key tools configured in `tools.nix`:
- **Terminal**: starship, zellij, tmux
- **File operations**: eza, bat, fzf, yazi
- **Git**: git with delta, lazygit
- **Development**: helix, direnv, just
- **System**: btop, duf, du-dust
- **Text processing**: sd, difftastic, ripgrep