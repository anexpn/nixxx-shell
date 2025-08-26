{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shell.tools.core;
in {
  options = {
    shell.tools.core = {
      enable =
        mkEnableOption "Core shell tools"
        // {
          description = ''
            Essential modern replacements for traditional Unix tools.
            These are daily-use tools that enhance productivity with better defaults,
            colors, and user-friendly interfaces.
          '';
        };

      # Alternative tool options
      fuzzy-finder = mkOption {
        type = types.enum ["fzf" "skim"];
        default = "fzf";
        description = "Choose fuzzy finder tool";
      };

      file-manager = mkOption {
        type = types.enum ["yazi" "broot" "none"];
        default = "yazi";
        description = "Choose terminal file manager";
      };

      pager = mkOption {
        type = types.enum ["bat" "less"];
        default = "bat";
        description = "Choose pager/cat replacement";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        # File Operations - always included
        eza # better ls
        fd # better find
        ripgrep # better grep

        # Text Processing
        sd # better sed
        choose # better cut
        jq # JSON processor

        # System Monitoring
        duf # better df
        du-dust # better du
        procs # better ps

        # Navigation & Search
        zoxide # better cd

        # HTTP Tools
        curl # traditional HTTP client

        # File Management
        trash-cli # safe deletion
        ouch # universal archive tool
      ]
      ++
      # Alternative fuzzy finders
      (
        if cfg.fuzzy-finder == "fzf"
        then [fzf]
        else [skim]
      )
      ++
      # Alternative file managers
      (
        if cfg.file-manager == "yazi"
        then [yazi]
        else if cfg.file-manager == "broot"
        then [broot]
        else []
      )
      ++
      # Alternative pagers
      (
        if cfg.pager == "bat"
        then [bat]
        else []
      );

    programs = mkMerge [
      {
        eza.enable = true;
        zoxide.enable = true;
        man = {
          generateCaches = true;
        };
      }

      # Conditional program configurations
      (mkIf (cfg.pager == "bat") {
        bat = {
          enable = true;
          config = {theme = "TwoDark";};
        };
        zsh = {
          initContent = ''
            # Global aliases for help output with bat syntax highlighting
            alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
            alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
          '';
        };
      })

      (mkIf (cfg.fuzzy-finder == "fzf") {
        fzf = {
          enable = true;
          defaultCommand = "rg --files --hidden --glob '!.git'";
          defaultOptions =
            ["--height=40%" "--layout=reverse" "--border" "--margin=1" "--padding=1"]
            ++ (optionals (cfg.pager == "bat") ["--preview" "'bat --color=always --style=numbers --line-range=:500 {}'"]);
        };
      })
    ];

    # Compatibility aliases for smooth transition
    home.shellAliases = mkMerge [
      {
        # File operations
        ls = "eza";
        ll = "eza -la";
        find = "fd";
        grep = "rg";

        # System monitoring
        du = "dust";
        df = "duf";
        ps = "procs";

        # Text processing
        sed = "sd";
        cut = "choose";

        # Navigation
        cd = "z"; # zoxide smart cd
      }

      # Conditional aliases based on choices
      (mkIf (cfg.pager == "bat") {
        cat = "bat --paging=never";
        less = "bat";
        man = "MANPAGER=\"sh -c 'awk '\\''{ gsub(/\\x1B\\[[0-9;]*m/, \\\"\\\", \\$0); gsub(/.\\x08/, \\\"\\\", \\$0); print }'\\'' | bat -p -lman'\" man";
      })
    ];
  };
}
