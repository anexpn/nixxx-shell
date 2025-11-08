# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Nix flake that provides modular shell configuration for development environments. It uses Home Manager modules to configure shells (Zsh, Nushell) and development tools in a cross-platform way.

## Architecture

The project follows a modular structure with Home Manager modules:

- `flake.nix` - Main flake definition with cross-platform support
- `homeModules/` - Contains all Home Manager modules (note: renamed from homeManagerModules)
  - `default.nix` - Root module that imports shell modules
  - `shell/default.nix` - Imports all shell-related modules
  - `shell/zsh.nix` - Extended Zsh configuration with Oh My Zsh
  - `shell/nushell.nix` - Extended Nushell with git aliases and custom functions
  - `shell/tmux.nix` - Extended tmux configuration with plugins and Neovim integration
  - `shell/tools.nix` - Main tools module with legacy simple mode
  - `shell/tools-*.nix` - Modular tool category modules (core, development, monitoring, etc.)
  - `shell/tools-scenarios.nix` - Scenario-based tool configurations
  - `shell/nb.nix` - Note-taking tools and utilities
- `scripts/` - Utility scripts
  - `tools` - Ruby script to display installed tools from the flake

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
nix build .#homeModules.default

# Check syntax of Nix files
nix-instantiate --parse <file.nix>
```

### Script Testing
Scripts can be tested by including them in your shell configuration:

```bash
# Show installed tools
tools

# Show all tools (installed and available)
tools --all
```

## Module Structure

Each module follows the standard Home Manager pattern:
- `options` - Define configuration options with `mkEnableOption`
- `config` - Implementation using `mkIf` for conditional configuration

The modules are designed to be composable with multiple configuration approaches:

### Shell Configuration
- `programs.zsh.extended.enable` - Enhanced Zsh with Oh My Zsh
- `programs.nushell.extended.enable` - Nushell with git aliases
- `programs.tmux.extended.enable` - Tmux with plugins and Neovim integration
- `shell.nb.enable` - Note-taking toolkit

### Tool Configuration (Multiple Approaches)

#### 1. Legacy Simple Mode
```nix
shell.tools.enable = true;  # Enables all essential tool categories
```

#### 2. Modular Category Mode
```nix
shell.tools = {
  core.enable = true;        # Essential modern CLI replacements
  development.enable = true; # Git, editors, analysis tools
  monitoring.enable = true;  # System monitoring and performance
  database.enable = false;   # Database and query tools (optional)
  container.enable = false;  # Container and cloud tools (optional)
  terminal.enable = true;    # Terminal multiplexers and productivity
};
```

#### 3. Scenario-Based Mode
```nix
shell.scenarios = {
  daily-driver.enable = true;     # Full-featured development setup
  # OR
  container.enable = true;        # Minimal container setup
  # OR  
  remote.enable = true;           # Remote server optimized
  
  # Language-specific add-ons
  language-specific = {
    rust.enable = true;
    node.enable = true;
    devops.enable = true;
  };
};
```

#### 4. Custom Tool Alternatives
```nix
shell.tools = {
  core = {
    enable = true;
    fuzzy-finder = "skim";      # Alternative: "fzf" (default)
    file-manager = "broot";     # Alternatives: "yazi" (default), "none"
    pager = "less";             # Alternative: "bat" (default)
  };
  development = {
    enable = true;
    code-counter = "scc";       # Alternative: "tokei" (default)
    editor = "none";            # Alternative: "helix" (default)
    git-ui = "tig";             # Alternatives: "lazygit" (default), "none"
  };
};
```

## Configuration Patterns

- Use `mkEnableOption` for boolean options
- Use `mkIf cfg.enable` for conditional configuration
- Support both vanilla and extended configurations where applicable
- Include local configuration file support (`.zshrc.local`, `.zshenv.local`)

## Cross-Platform Support

The flake supports multiple platforms via the `systems` attribute:
- x86_64-linux, aarch64-linux
- x86_64-darwin, aarch64-darwin (macOS)

## Tool Categories

**Core Tools** (Essential daily-use replacements):
- **File operations**: eza (ls), bat (cat), fd (find), ripgrep (grep)
- **System monitoring**: duf (df), du-dust (du), procs (ps)
- **Text processing**: sd (sed), choose (cut), jq (JSON)
- **Navigation**: fzf/skim (fuzzy finder), zoxide (smart cd)
- **Scripting**: ruby

**Development Tools**:
- **Version control**: git with delta, lazygit/tig, gh, gitleaks
- **Editors**: helix (modal editor)
- **Analysis**: shellcheck, tokei/scc (code counter), hyperfine
- **Build tools**: just (make alternative), direnv
- **AI**: aichat

**Monitoring & Network**:
- **System**: btop, bandwhich, gping
- **HTTP**: httpie, curl
- **Logs**: lnav

**Database & Query**: sqlite, dsq, xsv
**Container & Cloud**: dive, ctop, podman, k9s (Linux)
**Terminal Productivity**: starship, zellij, tmux, mcfly, kitty

### Compatibility & Migration

**Automatic aliases** for smooth transition:
```bash
ls → eza              cat → bat (if enabled)
du → dust             df → duf
ps → procs            sed → sd
cut → choose
```

**Note**: `find`, `grep`, and `cd` are NOT aliased to preserve traditional behavior. Use `fd`, `rg`, and `z` explicitly if desired.

## Development Environment

### Module Development Patterns

When adding new modules or tools:

1. **Tool Categories**: Add to appropriate `tools-*.nix` file (core, development, monitoring, etc.)
2. **Configuration Options**: Use `mkEnableOption` for boolean toggles, `lib.mkOption` for complex options
3. **Conditional Logic**: Wrap configurations in `mkIf cfg.enable` blocks
4. **Cross-Platform**: Consider platform-specific tools using `lib.optionals pkgs.stdenv.isLinux`
5. **Alternatives**: Support tool alternatives via enum options where appropriate

### Script Integration

The `tools` script in `/scripts/` displays all installed tools:
- Written in Ruby for simplicity
- Shows only installed tools by default
- Use `tools --all` to see available but not installed tools
- Color-coded output for better readability
- When you want to use git, you should use the jujutsu skill.