{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shell.tools.monitoring;
in {
  options = {
    shell.tools.monitoring = {
      enable = mkEnableOption "System monitoring tools" // {
        description = ''
          Advanced system monitoring, performance analysis, and network tools
          for understanding system behavior and troubleshooting.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # System Monitoring
      btop # system monitor
      
      # Network Monitoring
      bandwhich # network bandwidth by process
      gping # visual ping
      
      # HTTP Tools
      httpie # user-friendly HTTP client
      
      # Log Analysis
      lnav # log file navigator
    ];
    
    programs = {
      btop.enable = true;
    };
  };
}