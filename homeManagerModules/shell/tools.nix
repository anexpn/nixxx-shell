{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shell.tools;
in {
  imports = [
    ./tools-core.nix
    ./tools-development.nix
    ./tools-monitoring.nix
    ./tools-database.nix
    ./tools-container.nix
    ./tools-terminal.nix
    ./tools-scenarios.nix
  ];
  
  options = {
    shell.tools = {
      enable = mkEnableOption "Shell tools collection" // {
        description = ''
          Enable a curated collection of modern CLI tools and development utilities.
          This is a legacy option that enables all tool categories for compatibility.
          For fine-grained control, use individual tool categories instead.
        '';
      };
      
      # New modular options
      core = {
        enable = mkOption {
          type = types.bool;
          default = cfg.enable;
          description = "Enable core shell tools (essential replacements)";
        };
      };
      
      development = {
        enable = mkOption {
          type = types.bool;
          default = cfg.enable;
          description = "Enable development tools";
        };
      };
      
      monitoring = {
        enable = mkOption {
          type = types.bool;
          default = cfg.enable;
          description = "Enable system monitoring tools";
        };
      };
      
      database = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable database and query tools";
        };
      };
      
      container = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable container and cloud tools";
        };
      };
      
      terminal = {
        enable = mkOption {
          type = types.bool;
          default = cfg.enable;
          description = "Enable terminal multiplexers and productivity tools";
        };
      };
    };
  };
  config = mkMerge [
    # Legacy compatibility - when shell.tools.enable is used, enable all categories
    (mkIf cfg.enable {
      shell.tools = {
        core.enable = mkDefault true;
        development.enable = mkDefault true;
        monitoring.enable = mkDefault true;
        terminal.enable = mkDefault true;
        # Optional categories remain disabled by default
        database.enable = mkDefault false;
        container.enable = mkDefault false;
      };
    })
    
    # Tools script and common configuration
    (mkIf (cfg.core.enable || cfg.development.enable || cfg.monitoring.enable || cfg.terminal.enable || cfg.database.enable || cfg.container.enable) {
      assertions = [
        {
          assertion = pkgs.stdenv.isLinux || pkgs.stdenv.isDarwin;
          message = "Shell tools collection only supports Linux and macOS platforms";
        }
        
        # Platform-specific tool validation
        {
          assertion = !cfg.container.enable || pkgs.stdenv.isLinux || (!pkgs.stdenv.isLinux -> 
            (builtins.trace "Warning: Container tools (k9s) are Linux-only, some tools will be unavailable on macOS" true));
          message = "Container tools category includes Linux-specific tools that won't be available on other platforms";
        }
        
        # Scenario conflict validation
        {
          assertion = let
            scenarios = with config.shell.scenarios; [
              daily-driver.enable
              container.enable  
              remote.enable
            ];
            enabledScenarios = builtins.filter (x: x) scenarios;
          in (builtins.length enabledScenarios) <= 1;
          message = "Only one scenario can be enabled at a time (daily-driver, container, or remote)";
        }
        
        # Core tools dependency validation
        {
          assertion = !cfg.development.enable || cfg.core.enable;
          message = "Development tools require core tools to be enabled. Enable shell.tools.core.enable = true";
        }
        
        # Basic configuration validation - tool alternative validation is handled by individual modules
      ];
      
      # Enhanced tools and project detection scripts
      home.packages = [
        (pkgs.writeShellScriptBin "tools" (builtins.readFile ../../scripts/tools))
        (pkgs.writeShellScriptBin "tools-enhanced" (builtins.readFile ../../scripts/tools-enhanced))
        (pkgs.writeShellScriptBin "project-detect" (builtins.readFile ../../scripts/project-detect))
      ];
    })
  ];
}