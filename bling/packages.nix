{ pkgs, ... }:
{
  none = with pkgs; [
    git
  ];
  low = with pkgs; [
    htop
    github-cli
    glab
  ] ++ none;
  default = with pkgs; [
    fzf
    ripgrep
    vscode
  ] ++ low;
  high = with pkgs; [
    lazygit
    jq
    yq
    neovim
    neofetch
    btop
    cheat
  ] ++ default;
}
