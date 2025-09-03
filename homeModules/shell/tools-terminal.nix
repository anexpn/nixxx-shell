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
      mosh
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
        baseIndex = 1;
        clock24 = true;
        keyMode = "vi";
        mouse = true;
        terminal = "tmux-256color";
        escapeTime = 10;
        shortcut = "a";
        plugins = with pkgs.tmuxPlugins; [
          cpu
          {
            plugin = resurrect;
            extraConfig = "set -g @resurrect-strategy-nvim 'session'";
          }
          {
            plugin = continuum;
            extraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '60'
            '';
          }
          {
            plugin = catppuccin;
            extraConfig = ''
              set -g @catppuccin_flavour 'frappe'
              set -g @catppuccin_window_status_style "rounded"
              set -g @catppuccin_window_text " #W: #T"
              set -g @catppuccin_window_current_text " #W: #T"
            '';
          }
          tmux-sessionx
          tmux-fzf
          tmux-floax
        ];
        tmuxp.enable = true;
        extraConfig = ''
          set-option -sa terminal-features ',xterm-256color:RGB'
          # Make the status line more pleasant.
          set -g status-left ""

          # Ensure that everything on the right side of the status line
          # is included.
          set -g status-right-length 100
          set -g status-right "#{E:@catppuccin_status_application}"
          set -ag status-right "#{E:@catppuccin_status_session}"

          # '@pane-is-vim' is a pane-local option that is set by the plugin on load,
          # and unset when Neovim exits or suspends; note that this means you'll probably
          # not want to lazy-load smart-splits.nvim, as the variable won't be set until
          # the plugin is loaded

          # Smart pane switching with awareness of Neovim splits.
          # bind-key -n C-h if -F "#{@pane-is-vim}" 'send-keys C-h'  'select-pane -L'
          # bind-key -n C-j if -F "#{@pane-is-vim}" 'send-keys C-j'  'select-pane -D'
          # bind-key -n C-k if -F "#{@pane-is-vim}" 'send-keys C-k'  'select-pane -U'
          # bind-key -n C-l if -F "#{@pane-is-vim}" 'send-keys C-l'  'select-pane -R'

          # Alternatively, if you want to disable wrapping when moving in non-neovim panes, use these bindings
          bind-key -n C-h if -F '#{@pane-is-vim}' { send-keys C-h } { if -F '#{pane_at_left}'   "" 'select-pane -L' }
          bind-key -n C-j if -F '#{@pane-is-vim}' { send-keys C-j } { if -F '#{pane_at_bottom}' "" 'select-pane -D' }
          bind-key -n C-k if -F '#{@pane-is-vim}' { send-keys C-k } { if -F '#{pane_at_top}'    "" 'select-pane -U' }
          bind-key -n C-l if -F '#{@pane-is-vim}' { send-keys C-l } { if -F '#{pane_at_right}'  "" 'select-pane -R' }

          # Smart pane resizing with awareness of Neovim splits.
          bind-key -n M-h if -F "#{@pane-is-vim}" 'send-keys M-h' 'resize-pane -L 3'
          bind-key -n M-j if -F "#{@pane-is-vim}" 'send-keys M-j' 'resize-pane -D 3'
          bind-key -n M-k if -F "#{@pane-is-vim}" 'send-keys M-k' 'resize-pane -U 3'
          bind-key -n M-l if -F "#{@pane-is-vim}" 'send-keys M-l' 'resize-pane -R 3'

          tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
          if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
              "bind-key -n 'C-\\' if -F \"#{@pane-is-vim}\" 'send-keys C-\\'  'select-pane -l'"
          if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
              "bind-key -n 'C-\\' if -F \"#{@pane-is-vim}\" 'send-keys C-\\\\'  'select-pane -l'"

          bind-key -T copy-mode-vi 'C-h' select-pane -L
          bind-key -T copy-mode-vi 'C-j' select-pane -D
          bind-key -T copy-mode-vi 'C-k' select-pane -U
          bind-key -T copy-mode-vi 'C-l' select-pane -R
          bind-key -T copy-mode-vi 'C-\' select-pane -l
        '';
      };
    };
  };
}
