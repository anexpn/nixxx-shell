# ABOUTME: Comprehensive tmux configuration with plugins and Neovim integration
# ABOUTME: Provides session management, pane navigation, and persistent sessions
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.tmux.extended;
in {
  options = {
    programs.tmux.extended = {
      enable = mkEnableOption "Extended tmux configuration" // {
        description = ''
          Extended tmux configuration with plugins, Neovim integration,
          session management, and Catppuccin theming.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
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
}
