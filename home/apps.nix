{ pkgs, ... }:
{
  home.packages = with pkgs; [
    vscodium
    obsidian
    ayugram-desktop
    vlc
    gh
    bat
    duf
    kdePackages.ark
    kdePackages.gwenview
  ];
}
