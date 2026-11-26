{ inputs, ... }:
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
    ./caelestia.nix
    ./dotfiles.nix
    ./monitors.nix
    ./services.nix
    ./apps.nix
    ./office.nix
  ];

  home = {
    username = "vyto4ka";
    homeDirectory = "/home/vyto4ka";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  # wayland.windowManager.hyprland и programs.fish намеренно выключены:
  # конфигурацией управляют системные модули и дотсы Caelestia.

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
    };
  };

  xdg.configFile = {
    "environment.d/10-wayland-ozone.conf".text = ''
      XDG_SESSION_TYPE=wayland
      NIXOS_OZONE_WL=1
      ELECTRON_OZONE_PLATFORM_HINT=auto
    '';

    "hypr/xdph.conf".text = ''
      screencopy {
        allow_token_by_default = true
        force_shm = true
      }
    '';
  };
}
