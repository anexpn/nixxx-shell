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