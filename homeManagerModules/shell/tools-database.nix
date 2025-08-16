{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.shell.tools.database;
in {
  options = {
    shell.tools.database = {
      enable = mkEnableOption "Database and query tools" // {
        description = ''
          Tools for working with databases, CSV files, JSON data,
          and performing SQL-like queries on various data formats.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Database Tools
      sqlite # SQLite CLI
      
      # Data Processing
      dsq # SQL queries on JSON/CSV/etc
      xsv # CSV toolkit
      
      # Already included in core but important for data work
      jq # JSON processor (if not in core)
    ];
  };
}