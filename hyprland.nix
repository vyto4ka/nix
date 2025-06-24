{ config, pkgs, ... }:

let
  hyprcommandPkg = pkgs.callPackage ./programs/hyprcommand/default.nix {};
in {
  programs.hyprland.enable = true;
  programs.sway.enable     = true;

  services.displayManager.sddm.enable         = true;
  services.displayManager.sddm.wayland.enable = true;

  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    hyprland hyprpaper hyprlock hypridle hyprshot
    hyprpicker hyprpolkitagent hyprcommandPkg # hyper
    hyprsome 
    waybar swaynotificationcenter # bar
    wofi wlogout
    mako libnotify pavucontrol # screenshot
    playerctl acpi acpilight brightnessctl # power
    networkmanagerapplet blueman # net
    copyq socat jq wl-clipboard # util
    libsForQt5.qtstyleplugin-kvantum libsForQt5.qt5ct # style
    kdePackages.ark kdePackages.gwenview
    kdePackages.korganizer desktop-file-utils
  ];
}