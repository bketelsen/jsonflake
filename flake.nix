{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = { url = "github:hercules-ci/flake-parts"; inputs.nixpkgs-lib.follows = "nixpkgs"; };
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    nixos-flake.url = "github:bketelsen/nixos-flake";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

    imports = [ inputs.nixos-flake.flakeModule ];

    flake = {
      homeModules = inputs.nixpkgs.lib.genAttrs [ "high" "low" "none" "default" ] (x: ./bling/${x}.nix);

      templates.default = {
        description = "A `home-manager` template providing useful tools & settings for Nix-based development";
        path = builtins.path { path = inputs.nixpkgs.lib.cleanSource ./.; filter = path: _: baseNameOf path != "build.sh"; };
      };
    };

    perSystem = { pkgs, config, lib, ... }:
      let
        fleekConfig = lib.importJSON ./.fleek.json;
      in
      {
        legacyPackages.homeConfigurations."beast" = inputs.nixos-flake.lib.mkHomeConfiguration pkgs ({ pkgs, ... }: {
          imports = [ config.flake.homeModules.${fleekConfig.bling or "default"} ];

          home = {
            inherit (fleekConfig) username;
            homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${fleekConfig.username}";
            stateVersion = "22.11";
          };
        });

        packages.default = config.legacyPackages.homeConfigurations.${fleekConfig.username}.activationPackage;
      };
  };
}