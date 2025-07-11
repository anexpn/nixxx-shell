# Shell Configuration Flake

A standalone Nix flake providing shell configuration for development environments.

## Features

- **Zsh**: Extended configuration with Oh My Zsh plugins
- **Nushell**: Custom configuration with git aliases and plotting functions
- **Tools**: Modern CLI tools collection (bat, eza, fzf, starship, etc.)
- **Nb**: Note-taking tools and utilities

## Usage

Add this flake as an input to your configuration:

```nix
{
  inputs = {
    # ... other inputs
    my-shell.url = "github:juxtaly/nixxx-shell";
  };
}
```

Then import the home manager module:

```nix
{
  imports = [
    inputs.my-shell.homeManagerModules.default
  ];
  
  # Enable desired components
  programs.zsh.extended.enable = true;
  programs.nushell.extended.enable = true;
  shell.tools.enable = true;
  shell.nb.enable = true;
}
```

## Components

### Extended Zsh (`programs.zsh.extended`)
- Oh My Zsh integration with git plugins
- Auto-completion and syntax highlighting
- Local configuration file support
- `vanilla` option for minimal setup

### Extended Nushell (`programs.nushell.extended`)
- Git aliases (gst, ga, gc, etc.)
- Custom `cloc-plot` function for code analysis
- Session variables integration

### Shell Tools (`shell.tools`)
- Modern CLI replacements (bat, eza, duf, etc.)
- Development tools (git, starship, fzf, direnv)
- Terminal multiplexer (zellij, tmux)
- Text editors (helix)
- System monitoring (btop)

### Nb Tools (`shell.nb`)
- Note-taking with nb
- Web tools (w3m, readability-cli)
- Git utilities (tig)
- Documentation tools (glow, pandoc)

## Cross-Platform Support

This flake supports:
- x86_64-linux
- aarch64-linux  
- x86_64-darwin (macOS Intel)
- aarch64-darwin (macOS Apple Silicon)