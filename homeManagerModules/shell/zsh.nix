{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.zsh.extended;
in {
  options = {
    programs.zsh.extended = {
      enable = mkEnableOption "Extended Zsh configuration" // {
        description = ''
          Enable enhanced Zsh configuration with Oh My Zsh integration.
          Includes autosuggestions, syntax highlighting, and popular plugins.
          Supports local configuration files (~/.zshrc.local and ~/.zshenv.local).
        '';
      };
      vanilla = mkOption {
        default = false;
        example = true;
        description = ''
          Whether to use vanilla zsh without Oh My Zsh enhancements.
          When true, disables Oh My Zsh plugins and themes but keeps
          local configuration file support.
        '';
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    programs.zsh = mkMerge [
      {
        enable = true;
        initExtra = ''
          # Daily tool tip - show once per day
          show_daily_tip() {
            local tip_file="$HOME/.cache/nixxx-shell-tip"
            local today=$(date +%Y-%m-%d)
            
            if [[ ! -f "$tip_file" ]] || [[ "$(cat "$tip_file" 2>/dev/null)" != "$today" ]]; then
              mkdir -p "$(dirname "$tip_file")"
              echo "$today" > "$tip_file"
              
              local tips=(
                # File operations
                "💡 Use 'fd pattern' instead of 'find . -name pattern' - it's faster!"
                "💡 Use 'bat file' instead of 'cat file' - syntax highlighting!"
                "💡 Use 'eza -la' instead of 'ls -la' - modern file listing with icons"
                "💡 Use 'eza --tree' to see directory structure like 'tree'"
                "💡 Use 'yazi' for a visual file manager in terminal"
                "💡 Use 'trash file' instead of 'rm file' - safer deletion"
                "💡 Use 'ouch compress archive.zip file1 file2' for easy archiving"
                "💡 Use 'ouch decompress archive.zip' to extract any archive format"
                
                # Text processing
                "💡 Use 'rg pattern' instead of 'grep -r pattern' - much faster recursive search"
                "💡 Use 'sd old new file' instead of 'sed' - more intuitive find/replace"
                "💡 Use 'choose 1' instead of 'cut -f2' - human-friendly column selection"
                "💡 Use 'jq' to parse JSON: 'curl api.com | jq .field'"
                "💡 Use 'glow README.md' to view markdown files with formatting"
                
                # System monitoring
                "💡 Use 'procs' instead of 'ps aux' - better output formatting and filtering"
                "💡 Use 'duf' instead of 'df -h' - colorful disk usage overview"
                "💡 Use 'du-dust' instead of 'du -h' - visual directory size analysis"
                "💡 Use 'btop' instead of 'top' - beautiful resource monitor"
                
                # Development
                "💡 Use 'lazygit' for an interactive Git interface"
                "💡 Use 'gh repo view' to quickly check GitHub repo info"
                "💡 Use 'gh pr list' to see pull requests from command line"
                "💡 Use 'just --list' to see available commands (better than make)"
                "💡 Use 'helix file' (hx) for a modern modal editor"
                "💡 Use 'shellcheck script.sh' to check your shell scripts"
                "💡 Use 'tokei' to count lines of code by language"
                
                # Network & HTTP
                "💡 Use 'httpie' for user-friendly HTTP requests: 'http GET api.com'"
                "💡 Use 'curl -s url | jq' for quick API testing"
                
                # Terminal multiplexers
                "💡 Use 'zellij' for a modern terminal workspace with tabs"
                "💡 Use 'tmux' for persistent terminal sessions"
                
                # Navigation & search
                "💡 Use 'z dirname' (zoxide) to jump to frequently used directories"
                "💡 Use 'fzf' (Ctrl+R) for fuzzy command history search"
                "💡 Use 'mcfly' for intelligent command history with context"
                
                # Performance & benchmarking
                "💡 Use 'hyperfine cmd1 cmd2' to benchmark and compare commands"
                "💡 Use 'hyperfine --warmup 3 command' for accurate timing"
                
                # Documentation & help
                "💡 Use 'tldr command' for quick examples (powered by tealdeer)"
                "💡 Use 'tealdeer --update' to refresh the tldr database"
                
                # Database & logs
                "💡 Use 'sqlite3 db.sqlite' for quick database queries"
                "💡 Use 'lnav logfile' to analyze log files interactively"
                
                # Workflow tips
                "💡 Run 'tools' command to see all available CLI tools"
                "💡 Use 'direnv' to auto-load environment variables per directory"
                "💡 Combine tools: 'fd .rs | rg TODO' to find TODOs in Rust files"
                "💡 Use 'bat --style=numbers file' to show line numbers"
                "💡 Use 'fd -t f -e md | head -5' to find first 5 markdown files"
              )
              
              local random_tip=''${tips[$((RANDOM % ''${#tips[@]}))]}
              echo -e "\033[0;36m$random_tip\033[0m"
            fi
          }
          
          # Show tip on new shell (but not in scripts)
          if [[ -o interactive ]]; then
            show_daily_tip
          fi
          
          # Smart project detection on directory change
          smart_cd() {
            builtin cd "$@"
            
            # Only run project detection in interactive mode and if tools are available
            if [[ -o interactive ]] && command -v project-detect &>/dev/null; then
              # Check if this looks like a project directory
              if [[ -f "flake.nix" || -f "Cargo.toml" || -f "package.json" || -f "pyproject.toml" || -f "go.mod" || -f "main.tf" ]]; then
                echo
                project-detect detect . 2>/dev/null || true
              fi
            fi
          }
          
          # Override cd with smart version
          alias cd='smart_cd'
          
          if test -f ~/.zshrc.local; then
            . ~/.zshrc.local
          fi
        '';
        envExtra = ''
          if test -f ~/.zshenv.local; then
            . ~/.zshenv.local
          fi
        '';
      }
      (mkIf (!cfg.vanilla) (let
        omz = pkgs.fetchFromGitHub {
          owner = "ohmyzsh";
          repo = "ohmyzsh";
          rev = "fcceeb666452c5a41b786f3cde9c8635ddde5448";
          sha256 = "sha256-c929KV77wACO0AlEABwOPPz03Za8V4G7RRXalY+zfGg=";
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
      }))
    ];
  };
}