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
  - `shell/tools.nix` - Main tools module with legacy simple mode
  - `shell/tools-*.nix` - Modular tool category modules (core, development, monitoring, etc.)
  - `shell/tools-scenarios.nix` - Scenario-based tool configurations
  - `shell/nb.nix` - Note-taking tools and utilities
- `scripts/` - Utility scripts for tool discovery and project detection
  - `tools` - Enhanced tools overview and discovery script
  - `project-detect` - Smart project type detection and tool suggestions

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
# Test enhanced tools discovery
tools
tools alternatives
tools scenarios
tools categories

# Test project detection
project-detect
project-detect type
project-detect help
```

## Module Structure

Each module follows the standard Home Manager pattern:
- `options` - Define configuration options with `mkEnableOption`
- `config` - Implementation using `mkIf` for conditional configuration

The modules are designed to be composable with multiple configuration approaches:

### Shell Configuration
- `programs.zsh.extended.enable` - Enhanced Zsh with Oh My Zsh
- `programs.nushell.extended.enable` - Nushell with git aliases
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

## Enhanced Tools and Discovery

### Tool Categories

**Core Tools** (Essential daily-use replacements):
- **File operations**: eza (ls), bat (cat), fd (find), ripgrep (grep)
- **System monitoring**: duf (df), du-dust (du), procs (ps)
- **Text processing**: sd (sed), choose (cut), jq (JSON)
- **Navigation**: fzf/skim (fuzzy finder), zoxide (smart cd)

**Development Tools**:
- **Version control**: git with delta, lazygit/tig, gh, gitleaks
- **Editors**: helix (modal editor)
- **Analysis**: shellcheck, tokei/scc (code counter), hyperfine
- **Build tools**: just (make alternative), direnv

**Monitoring & Network**:
- **System**: btop, bandwhich, gping, broot
- **HTTP**: httpie, curl
- **Logs**: lnav

**Database & Query**: sqlite, dsq, xsv
**Container & Cloud**: dive, ctop, k9s (Linux)
**Terminal Productivity**: starship, zellij, tmux, mcfly

### Smart Discovery System

#### Enhanced Tools Script
```bash
tools                    # Show all available tools
tools alternatives       # Show tool alternatives and options
tools scenarios          # Show usage scenarios (daily-driver, container, remote)
tools categories         # Show tool categories
tools search <keyword>   # Search for tools by keyword
tools demo <tool>        # Show live demo of a tool
tools config             # Show configuration examples
```

#### Automatic Project Detection
```bash
project-detect           # Analyze current directory for project type
project-detect type      # Just show detected project types
```

**Smart features**:
- Auto-detects project types (Rust, Node.js, Python, Go, Nix, Docker, Terraform)
- Suggests relevant tools and commands
- Provides project-specific aliases
- Auto-runs when entering project directories (via enhanced `cd`)
- Generates `.envrc` for Nix projects

### Compatibility & Migration

**Automatic aliases** for smooth transition:
```bash
ls → eza              cat → bat (if enabled)
du → dust             df → duf
ps → procs            sed → sd
cut → choose
```

**Note**: `find`, `grep`, and `cd` are NOT aliased to preserve traditional behavior. Use `fd`, `rg`, and `z` explicitly if desired.

**Migration assistance**:
- Daily tips system shows modern tool alternatives
- Context-aware suggestions based on project type
- Progressive disclosure of advanced features

## Development Environment

### Module Development Patterns

When adding new modules or tools:

1. **Tool Categories**: Add to appropriate `tools-*.nix` file (core, development, monitoring, etc.)
2. **Configuration Options**: Use `mkEnableOption` for boolean toggles, `lib.mkOption` for complex options
3. **Conditional Logic**: Wrap configurations in `mkIf cfg.enable` blocks
4. **Cross-Platform**: Consider platform-specific tools using `lib.optionals pkgs.stdenv.isLinux`
5. **Alternatives**: Support tool alternatives via enum options where appropriate

### Script Integration

Scripts in `/scripts/` can be included in shell configurations:
- Scripts use bash with `set -euo pipefail` for strict error handling
- Color output using ANSI codes for better UX
- Structured help systems with `command help` pattern
- Project detection uses file-based heuristics for accuracy