{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shell.nb;
in {
  options = {
    shell.nb = {
      enable = mkEnableOption "Nb note-taking tools";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nb
      w3m
      socat
      tig
      glow
      readability-cli
    ];
    programs = {
      bat = {
        enable = true;
      };
      ripgrep = {
        enable = true;
      };
      pandoc = {
        enable = true;
      };
    };
  };
}