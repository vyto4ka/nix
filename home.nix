{ config, pkgs, lib, ... }:

let
  configDir    = ./config;
  configEntries = builtins.readDir configDir;

  configFiles = lib.mapAttrs' (name: type: {
    name = name;
    value = {
      source = configDir + "/${name}";
      force  = true;
    };
  }) configEntries;
in
{
  nixpkgs.config.allowUnfree = true;

  home.stateVersion    = "24.11";
  home.username        = "vyto4ka";
  home.homeDirectory   = "/home/vyto4ka";

  home.packages = with pkgs; [
    fish firefox nekoray kitty thunderbird telegram-desktop termius nordic
    git alacritty
    vscodium gcc netbeans neofetch duf bat jdk11 
    fastfetch cowsay 
    ponysay fortune 
    libreoffice-still hunspell hunspellDicts.ru_RU
    neovim btop
  ];

  home.sessionVariables = {
    TERMINAL = "alacritty";
  };

  xdg.configFile = configFiles;

  programs.alacritty.enable  = true;

  programs.bash.enable       = true;
  services.kdeconnect.enable = true;

  gtk = {
    enable = true;

    theme = {
      package = pkgs.tokyonight-gtk-theme;
      name = "Tokyonight-Dark";
    };
  };   
}
