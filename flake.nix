{
  description = "Shell configuration for atriw";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      
      flake.homeManagerModules = {
        default = import ./homeManagerModules;
        shell = import ./homeManagerModules;
      };
      
      perSystem = {pkgs, ...}: {
        # Development shell for testing the flake
        devShells.default = pkgs.mkShell {
          name = "nixxx-shell-test";
          
          # Test with core tools enabled
          buildInputs = with pkgs; [
            # Core tools from tools-core.nix
            eza bat fd ripgrep sd choose jq
            duf du-dust procs zoxide
            trash-cli ouch fzf yazi
            
            # Development tools
            git delta lazygit gh shellcheck
            tokei just direnv helix
            
            # Terminal tools  
            starship zellij tmux
            
            # Monitoring tools
            btop httpie curl glow
            
            # Test scripts
            (writeShellScriptBin "test-tools" ''
              echo "Testing nixxx-shell tools..."
              echo "Core tools available:"
              command -v eza && echo "✓ eza (ls replacement)"
              command -v bat && echo "✓ bat (cat replacement)" 
              command -v fd && echo "✓ fd (find replacement)"
              command -v rg && echo "✓ ripgrep (grep replacement)"
              command -v fzf && echo "✓ fzf (fuzzy finder)"
              echo "Run 'tools' to see all available tools"
            '')
            
            # Include the tools script (only if file exists)
            (writeShellScriptBin "tools" (if builtins.pathExists ./scripts/tools 
              then builtins.readFile ./scripts/tools 
              else "echo 'Tools script not available in test environment'"))
          ];
          
          shellHook = ''
            echo "🚀 nixxx-shell test environment"
            echo "Run 'test-tools' to verify tools are working"
            echo "Run 'tools' to see available tools"
            echo "Run 'project-detect' to test project detection"
            
            # Set up basic aliases for testing
            alias ls='eza'
            alias cat='bat --paging=never'
            alias find='fd'
            alias grep='rg'
          '';
        };
        
        # Alternative shell with just core tools
        devShells.core = pkgs.mkShell {
          name = "nixxx-shell-core-test";
          buildInputs = with pkgs; [
            eza bat fd ripgrep sd choose jq
            duf du-dust procs zoxide trash-cli ouch
            (writeShellScriptBin "tools" (if builtins.pathExists ./scripts/tools 
              then builtins.readFile ./scripts/tools 
              else "echo 'Tools script not available in test environment'"))
          ];
          shellHook = ''
            echo "🔧 nixxx-shell core tools test"
            alias ls='eza'
            alias cat='bat --paging=never'
            alias find='fd'
            alias grep='rg'
          '';
        };
      };
    };
}