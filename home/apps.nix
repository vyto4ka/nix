{ pkgs, inputs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  home.packages = with pkgs; [
    vscodium
    antigravity-hub
    antigravity-ide
    antigravity-cli
    inputs.vysh.packages.${system}.default
    obsidian
    ayugram-desktop
    vesktop
    vlc
    bat
    duf
    kdePackages.ark
    kdePackages.gwenview
  ];
}
