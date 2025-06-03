{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ./modules/home/kitty.nix
    ./modules/home/fetch.nix
  ];

  home.stateVersion    = "24.11";
  home.username        = "vyto4ka";
  home.homeDirectory   = "/home/vyto4ka";

  home.packages = with pkgs; [
    fish firefox nekoray kitty thunderbird telegram-desktop termius nordic
    git vscodium gcc netbeans neofetch duf bat jdk11 jdk17 fastfetch
  ];

  home.sessionVariables = {
    TERMINAL = "kitty";
  };

  programs.bash.enable = true;
  programs.kdeconnect.enable = true;

}