# Edit this to install packages and modify dotfile configuration in your
# $HOME.
#
# https://nix-community.github.io/home-manager/index.html#sec-usage-configuration
{ pkgs, ... }:
let
  fleekConfig = builtins.fromJSON (builtins.readFile ../.fleek.json);
  userPackages = map (x: pkgs.${x}) fleekConfig.packages;

in
{
  imports = [
    # Add your other home-manager modules here.
  ];

  # Nix packages to install to $HOME
  #
  # Search for packages here: https://search.nixos.org/packages

  home.packages = with pkgs; [
    git
  ] ++ userPackages;



  # Programs natively supported by home-manager.
  programs = {
    bash.enable = true;

    # For macOS's default shell.
    zsh = {
      enable = true;
      enableCompletion = fleekConfig.completion;
      envExtra = ''
        # Make Nix and home-manager installed things available in PATH.
        export PATH=/run/current-system/sw/bin/:$HOME/.nix-profile/bin:$PATH
      '';
    };

  };
}
