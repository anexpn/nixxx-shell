{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shell.tools.development;
in {
  options = {
    shell.tools.development = {
      enable = mkEnableOption "Development tools" // {
        description = ''
          Tools specifically for software development including version control,
          editors, code analysis, and project management utilities.
        '';
      };
      
      # Alternative tool options
      code-counter = mkOption {
        type = types.enum ["tokei" "scc"];
        default = "tokei";
        description = "Choose code line counter tool";
      };
      
      editor = mkOption {
        type = types.enum ["helix" "none"];
        default = "helix";
        description = "Choose terminal editor";
      };
      
      git-ui = mkOption {
        type = types.enum ["lazygit" "tig" "none"];
        default = "lazygit";
        description = "Choose Git TUI tool";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Version Control
      gh # GitHub CLI
      gitleaks # Git secrets detection
      jujutsu # Modern VCS compatible with Git
      
      # Code Analysis
      shellcheck # shell script analysis
      
      # Build & Task Running
      just # better make
      
      # Documentation
      glow # markdown viewer
      tealdeer # fast tldr client
      
      # Data Analysis
      lemmeknow # identify data formats
      grex # regex generator
      
      # AI Tools
      aichat # AI chat interface
      
      # Performance
      hyperfine # benchmarking
    ] ++ 
    # Alternative code counters
    (if cfg.code-counter == "tokei" then [tokei] else [scc]) ++
    # Alternative Git UIs
    (if cfg.git-ui == "lazygit" then [lazygit] 
     else if cfg.git-ui == "tig" then [tig] 
     else []) ++
    # Alternative editors (helix vs none)
    (if cfg.editor == "helix" then [helix] else []);
    
    programs = mkMerge [
      {
        git = {
          enable = true;
          delta.enable = true;
          extraConfig = {
            credential.helper = "store";
          };
        };
        pandoc.enable = true;
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
      }
      
      # Conditional program configurations
      (mkIf (cfg.git-ui == "lazygit") {
        lazygit.enable = true;
      })
      
      (mkIf (cfg.editor == "helix") {
        helix = {
          enable = true;
          settings = {
            theme = "catppuccin_frappe";
            editor = {
              lsp.display-messages = true;
            };
          };
        };
      })
    ];
  };
}
