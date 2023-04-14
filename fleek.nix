{ config, pkgs, lib, ... }:
let
  types = lib.types;
  fleekConfig = builtins.fromJSON (builtins.readFile ./.fleek.json);
in
{
  options = {

    name = lib.mkOption {
      type = types.nullOr types.str;
      description = "Name of the project.";
      default = null;
    };

    packages = lib.mkOption {
      type = types.listOf types.package;
      description = "A list of packages to expose inside the developer environment. Search available packages using ``devenv search NAME``.";
      default = [ ];
    };
  };

 
  config = {
    packages = builtins.trace fleekConfig.packages fleekConfig.packages;
  };
}