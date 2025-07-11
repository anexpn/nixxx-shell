{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shell.tools;
in {
  options = {
    shell.tools = {
      enable = mkEnableOption "Shell tools collection" // {
        description = ''
          Enable a curated collection of modern CLI tools and development utilities.
          This includes enhanced versions of common tools (eza for ls, bat for cat, etc.)
          and popular development tools (git with delta, tmux, helix editor, etc.).
        '';
      };
    };
  };
  config = mkIf cfg.enable (let
    packages = with pkgs; [
      httpie # curl
      curl # HTTP client
      duf # df
      du-dust # du
      sd # sed
      lnav # browse log files

      glow # markdown
      sqlite
      tokei
      shellcheck
      just # make
      yazi
      gh # GitHub CLI
      
      # Modern CLI tools
      fd # modern find
      jq # JSON processor
      procs # modern ps
      hyperfine # command benchmarking
      choose # human-friendly cut
      trash-cli # safe file deletion
      ouch # universal archive tool
      tealdeer # fast tldr client
    ];
    
    # Tools script to display available tools with descriptions
    toolsScript = pkgs.writeShellScriptBin "tools" (builtins.readFile ../../scripts/tools);
    programs = {
      git = {
        enable = true;
        delta.enable = true;
        extraConfig = {
          credential.helper = "store";
        };
      };
      starship = {
        enable = true;
      };
      eza = {
        enable = true;
      };
      bat = {
        enable = true;
        config = {theme = "TwoDark";};
      };
      fzf = {
        enable = true;
        defaultCommand = "rg --files --hidden --glob '!.git'";
        defaultOptions = ["--height=40%" "--layout=reverse" "--border" "--margin=1" "--padding=1"];
      };
      mcfly = {
        enable = true;
        keyScheme = "vim";
      };
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      zellij = {
        enable = true;
        settings = {
          pane_frames = false;
          default_mode = "locked";
          # default_layout = "compact";
          theme = "catppuccin-frappe";
          themes.catppuccin-frappe = {
            bg = "#626880";
            fg = "#c6d0f5";
            red = "#e78284";
            green = "#a6d189";
            blue = "#8caaee";
            yellow = "#e5c890";
            magenta = "#f4b8e4";
            orange = "#ef9f76";
            cyan = "#99d1db";
            black = "#292c3c";
            white = "#c6d0f5";
          };
        };
      };
      helix = {
        enable = true;
        settings = {
          theme = "catppuccin_frappe";
          editor = {
            lsp.display-messages = true;
          };
        };
      };
      btop = {
        enable = true;
      };
      lazygit = {
        enable = true;
      };
      pandoc = {
        enable = true;
      };
      zoxide = {
        enable = true;
      };
      tmux = {
        enable = true;
        terminal = "screen-256color";
        escapeTime = 10;
        plugins = with pkgs; [
          tmuxPlugins.cpu
          {
            plugin = tmuxPlugins.resurrect;
            extraConfig = "set -g @resurrect-strategy-nvim 'session'";
          }
          {
            plugin = tmuxPlugins.continuum;
            extraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '60'
            '';
          }
          {
            plugin = tmuxPlugins.catppuccin;
            extraConfig = ''
              set -g @catppuccin_flavour 'frappe'
            '';
          }
        ];
        extraConfig = ''
          set-option -sa terminal-features ',xterm-256color:RGB'
        '';
      };
    };
  in {
    assertions = [
      {
        assertion = pkgs.stdenv.isLinux || pkgs.stdenv.isDarwin;
        message = "Shell tools collection only supports Linux and macOS platforms";
      }
    ];
    
    home.packages = packages ++ [toolsScript];
    inherit programs;
  });
}