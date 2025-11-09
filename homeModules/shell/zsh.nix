{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shell.zsh;
in {
  options = {
    shell.zsh = {
      enable =
        mkEnableOption "Extended Zsh configuration"
        // {
          description = ''
            Enable enhanced Zsh configuration with Oh My Zsh integration.
            Includes autosuggestions, syntax highlighting, and popular plugins.
            Supports local configuration files (~/.zshrc.local and ~/.zshenv.local).
          '';
        };
    };
  };
  config = mkIf cfg.enable {
    programs.zsh = mkMerge [
      {
        enable = true;
        initContent = ''
          ${optionalString (config.shell.tmux.enable or false && config.shell.tmux.autoStart or false) ''
            # Auto-start tmux session
            if [[ -z "$TMUX_PANE" ]]; then
              tmux new-session -A -s "''${USER}"
            fi
          ''}

          if test -f ~/.zshrc.local; then
            . ~/.zshrc.local
          fi

          autoload -U edit-command-line
          zle -N edit-command-line
          bindkey '^xe' edit-command-line
          bindkey '^x^e' edit-command-line
        '';
        envExtra = ''
          if test -f ~/.zshenv.local; then
            . ~/.zshenv.local
          fi
        '';
      }
      (
        let
          omz = pkgs.fetchFromGitHub {
            owner = "ohmyzsh";
            repo = "ohmyzsh";
            rev = "90a22b61e66dbd83928be7b9739de554a5f1c09d";
            sha256 = "sha256-ODtuQ/jqo0caw4l/8tUe/1TizAaAA/bSqZhIEjSuVi8=";
          };
          plugins = [
            "git"
            "git-extras"
          ];
        in {
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          plugins =
            builtins.map (p: {
              name = "ohmyzsh/${p}";
              src = "${omz}/plugins/${p}";
              file = "${p}.plugin.zsh";
            })
            plugins;
        }
      )
    ];
  };
}
