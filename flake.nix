{
  description = "Shell configuration for atriw";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      
      flake = {
        homeManagerModules = {
          default = ./homeManagerModules;
          shell = ./homeManagerModules;
        };
      };
    };
}