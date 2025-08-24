{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shell.tools.terminal;
in {
  options = {
    shell.tools.terminal = {
      enable = mkEnableOption "Terminal multiplexers and productivity" // {
        description = ''
          Terminal multiplexers, session management, and productivity tools
          for advanced terminal workflows and workspace management.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
    ];
    
    programs = {
      kitty = {
        enable = true;
        font = {
          name = "Fira Code";
          package = pkgs.fira-code;
          size = 16.0;
        };
        settings = {

          # macOS specific settings
          macos_option_as_alt = true;
          
          # Catppuccin Mocha color scheme
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          cursor = "#f5e0dc";
          
          # Normal colors
          color0 = "#45475a";
          color1 = "#f38ba8";
          color2 = "#a6e3a1";
          color3 = "#f9e2af";
          color4 = "#89b4fa";
          color5 = "#f5c2e7";
          color6 = "#94e2d5";
          color7 = "#bac2de";
          
          # Bright colors
          color8 = "#585b70";
          color9 = "#f38ba8";
          color10 = "#a6e3a1";
          color11 = "#f9e2af";
          color12 = "#89b4fa";
          color13 = "#f5c2e7";
          color14 = "#94e2d5";
          color15 = "#a6adc8";
        };
      };
      starship.enable = true;
      mcfly = {
        enable = true;
        keyScheme = "vim";
      };
      zellij = {
        enable = true;
        settings = {
          pane_frames = false;
          default_mode = "locked";
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
  };
}
