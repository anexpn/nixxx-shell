{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shell.scenarios;
in {
  options = {
    shell.scenarios = {
      daily-driver = {
        enable = mkEnableOption "Daily driver configuration" // {
          description = ''
            Full-featured setup for primary development machine.
            Includes all productivity tools, editors, multiplexers, and monitoring.
          '';
        };
      };
      
      container = {
        enable = mkEnableOption "Container/minimal configuration" // {
          description = ''
            Lightweight setup for containers and minimal environments.
            Focus on essential tools with small footprint.
          '';
        };
      };
      
      remote = {
        enable = mkEnableOption "Remote server configuration" // {
          description = ''
            Tools optimized for remote servers and SSH sessions.
            Emphasizes terminal multiplexers and system monitoring.
          '';
        };
      };
      
      language-specific = {
        rust = mkEnableOption "Rust development tools";
        node = mkEnableOption "Node.js development tools";
        python = mkEnableOption "Python development tools";
        go = mkEnableOption "Go development tools";
        devops = mkEnableOption "DevOps and infrastructure tools";
      };
    };
  };
  
  config = mkMerge [
    # Daily driver scenario
    (mkIf cfg.daily-driver.enable {
      shell.tools = {
        core.enable = mkDefault true;
        development.enable = mkDefault true;
        monitoring.enable = mkDefault true;
        database.enable = mkDefault true;
        container.enable = mkDefault true;
        terminal.enable = mkDefault true;
      };
    })
    
    # Container scenario - minimal footprint
    (mkIf cfg.container.enable {
      shell.tools = {
        core.enable = mkDefault true;
        development.enable = mkDefault false;
        monitoring.enable = mkDefault false;
        database.enable = mkDefault false;
        container.enable = mkDefault false;
        terminal.enable = mkDefault false;
      };
    })
    
    # Remote server scenario
    (mkIf cfg.remote.enable {
      shell.tools = {
        core.enable = mkDefault true;
        development.enable = mkDefault false;
        monitoring.enable = mkDefault true;
        database.enable = mkDefault false;
        container.enable = mkDefault false;
        terminal.enable = mkDefault true;
      };
    })
    
    # Language-specific configurations
    (mkIf cfg.language-specific.rust {
      home.packages = with pkgs; [
        cargo
        rustc
        rust-analyzer
        clippy
        rustfmt
      ];
    })
    
    (mkIf cfg.language-specific.node {
      home.packages = with pkgs; [
        nodejs
        yarn
        pnpm
      ];
    })
    
    (mkIf cfg.language-specific.python {
      home.packages = with pkgs; [
        python3
        python3Packages.pip
        python3Packages.virtualenv
        ruff # fast Python linter
      ];
    })
    
    (mkIf cfg.language-specific.go {
      home.packages = with pkgs; [
        go
        golangci-lint
        gopls
      ];
    })
    
    (mkIf cfg.language-specific.devops {
      home.packages = with pkgs; [
        terraform
        ansible
        kubectl
        helm
        docker-compose
      ];
    })
  ];
}