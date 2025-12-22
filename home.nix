{ config, pkgs, lib, caelestia-shell, ... }:

let
  configDir     = ./config;
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

  home.stateVersion  = "24.11";
  home.username      = "vyto4ka";
  home.homeDirectory = "/home/vyto4ka";

  home.packages = with pkgs; [
    fish firefox nekoray kitty thunderbird telegram-desktop termius nordic
    git alacritty
    vscodium gcc netbeans neofetch duf bat jdk11
    fastfetch cowsay
    ponysay fortune
    libreoffice-still hunspell hunspellDicts.ru_RU
    neovim btop vlc
  ];

  home.sessionVariables = {
    TERMINAL = "alacritty";
  };

  xdg.configFile = configFiles;

  programs.alacritty.enable = true;

  programs.bash.enable = true;
  services.kdeconnect.enable = true;

  programs.caelestia = {
    enable = true;

    package = pkgs.callPackage "${caelestia-shell}/nix/default.nix" {
      "xkeyboard-config" = pkgs.xkeyboard_config;
      app2unit = pkgs.app2unit;

      brightnessctl = pkgs.brightnessctl;
      ddcutil = pkgs.ddcutil;
      cava = pkgs.cava;
      aubio = pkgs.aubio;
      lm_sensors = pkgs.lm_sensors;
      networkmanager = pkgs.networkmanager;
    };

    systemd.enable = false;

    cli.enable = true;

    settings = {
      paths.wallpaperDir = "~/.config/wallpaper";
    };
  };
}
