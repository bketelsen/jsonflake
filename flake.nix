{
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-flake.url = "github:bketelsen/nixos-flake";
  };

  outputs = inputs@{ self, ... }:
    let
      fleekConfig = builtins.fromJSON (builtins.readFile ./.fleek.json);
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      imports = [
        inputs.nixos-flake.flakeModule
        ./fleek.nix
      ];

      flake.homeModules.default = ./bling/default.nix;
      flake.homeModules.high = ./bling/high.nix;
      flake.homeModules.low = ./bling/low.nix;
      flake.homeModules.none = ./bling/none.nix;

      flake.fleekConfig = fleekConfig;

      flake.templates.default = {
        description = "A `home-manager` template providing useful tools & settings for Nix-based development";
        path = builtins.path {
          path = ./.;
          filter = path: _:
            inputs.nixpkgs.lib.hasSuffix ".nix" path ||
            inputs.nixpkgs.lib.hasSuffix ".lock" path;
        };
      };

      perSystem = { self', pkgs, ... }:
        {
          legacyPackages.homeConfigurations.beast =
            self.nixos-flake.lib.mkHomeConfiguration
              pkgs
              ({ pkgs, ... }: {
                imports = [ self.homeModules.high ];
                home.username = fleekConfig.username;
                home.homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${fleekConfig.username}";
                home.stateVersion = "22.11";
              });

          # Enables 'nix run' to activate.
          apps.default.program = self'.packages.activate-home;

          # Enable 'nix build' to build the home configuration, but without
          # activating.
          packages.default = self'.legacyPackages.homeConfigurations.${fleekConfig.username}.activationPackage;
        };
    };
}
