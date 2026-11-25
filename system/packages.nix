{ pkgs, inputs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;

  onlyofficeWithFonts = pkgs.onlyoffice-desktopeditors.override {
    extraFontPackages = with pkgs; [
      liberation_ttf
      carlito
      caladea
      dejavu_fonts
      noto-fonts
      rubik
    ];
  };
in
{
  environment.systemPackages = with pkgs; [
    # Плагины fish строго в системном профиле (vendor_conf.d подхватывается при выключенном HM fish)
    fishPlugins.plugin-git
    fishPlugins.forgit

    # Базовые утилиты и редактор
    curl
    git
    gh
    glib
    neovim

    # Темизация и окружение Caelestia (без papirus-folders, так как /nix/store только для чтения)
    adw-gtk3
    papirus-icon-theme
    qtengine
    darkly
    kdePackages.frameworkintegration
    bibata-cursors

    # Терминал, шелл-окружение и системные инструменты Caelestia
    foot
    eza
    zoxide
    direnv
    starship
    fastfetch
    btop
    micro
    cava
    pwvucontrol
    trash-cli
    jq
    ripgrep
    lazygit
    ydotool
    hyprpicker
    xdg-user-dirs
    gammastep

    # Ключевые CLI для прямого вызова из терминала и хоткеев
    grim
    slurp
    swappy
    wl-clipboard
    cliphist
    dart-sass
    gpu-screen-recorder
    ffmpeg
    libnotify
    brightnessctl
    playerctl

    # Браузеры
    inputs.zen-browser.packages.${system}.beta
    google-chrome

    # OnlyOffice с проброшенными свободными шрифтами (Windows-шрифты подхватываются из ~/.local/share/fonts/)
    onlyofficeWithFonts
  ];
}
