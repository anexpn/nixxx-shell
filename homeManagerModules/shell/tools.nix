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
      enable = mkEnableOption "Shell tools collection";
    };
  };
  config = let
    packages = with pkgs; [
      httpie # curl
      duf # df
      du-dust # du
      tldr # man
      sd # sed
      difftastic # diff
      lnav # browse log files

      gum # interactive shell script
      glow # markdown
      sqlite
      unzip
      cloc
      youplot # plot in terminal
      shellcheck
      just # make
      yazi
      gh # GitHub CLI
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
  in
    mkIf cfg.enable {
      home.packages = packages ++ [toolsScript];
      inherit programs;
    };
}