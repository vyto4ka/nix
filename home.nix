{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;
  imports = [
    ./modules/home/neovim.nix
    ./modules/home/kitty.nix
    ./modules/home/neofetch.nix
  ];

  home.stateVersion    = "24.11";
  home.username        = "vyto4ka";
  home.homeDirectory   = "/home/vyto4ka";

  home.packages = with pkgs; [
    fish firefox nekoray kitty thunderbird telegram-desktop termius nordic
    git vscodium gcc netbeans neofetch duf bat
  ];

  home.sessionVariables = {
    TERMINAL = "kitty";
  };

  programs.bash.enable = true;
}