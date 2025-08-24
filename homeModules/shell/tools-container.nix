{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shell.tools.container;
in {
  options = {
    shell.tools.container = {
      enable = mkEnableOption "Container and cloud tools" // {
        description = ''
          Tools for working with containers, Docker images, and Kubernetes.
          These tools help with container analysis, monitoring, and management.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Container Analysis
      dive # docker image analysis
      ctop # container resource monitor
      
      # Container Runtimes
      podman # daemonless container engine
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      # Linux-specific container tools
      k9s # kubernetes TUI
    ];
  };
}