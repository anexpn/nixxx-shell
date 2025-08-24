{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.nushell.extended;
in {
  options = {
    programs.nushell.extended = {
      enable = mkEnableOption "Extended Nushell configuration";
    };
  };
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.programs.nushell.enable || config.programs.nushell.enable;
        message = "programs.nushell.extended conflicts with manually enabled programs.nushell";
      }
    ];
    programs.nushell = {
      enable = true;
      shellAliases = {
        gst = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gd = "git diff";
        glog = "git log --oneline --decorate";
        glg = "git log --stat --patch";
      };
      configFile = {
        text = ''
          # Pipe cloc output to uplot to make barplot.
          # Example: cloc-plot . --include-ext=nix
          def --wrapped cloc-plot [
            files: string           # The files to scan
            --help (-h)             # Nushell help of this command
            --limit (-n): int = 15  # Limit the lines showed
            ...args: string         # Args passthrough
          ] {
            cloc $files ...$args --by-file --csv --quiet | head -n -1 | head -n $limit | cut -f2,5 -d, | uplot barplot -H -d,
          }
        '';
      };
      # Workaround
      # Nushell does not respect home.sessionVariables now.
      environmentVariables = builtins.mapAttrs (name: value: "\"${builtins.toString value}\"") config.home.sessionVariables;
    };
  };
}