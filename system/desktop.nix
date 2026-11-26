{ pkgs, ... }:
{
  console.useXkbConfig = true;

  # Включаем Wayland для Electron/Ozone; QT_QPA_PLATFORMTHEME и GTK_THEME не задаём глобально
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services = {
    # X11 отключён, но раскладка применяется к TTY и Wayland-греетеру SDDM
    xserver = {
      enable = false;
      xkb = {
        layout = "us,ru";
        options = "grp:win_space_toggle";
      };
    };

    # Запасная сессия KDE Plasma 6
    desktopManager.plasma6.enable = true;

    # GNOME Keyring с автоматической разблокировкой при входе в SDDM
    gnome.gnome-keyring.enable = true;

    gvfs.enable = true;
    tumbler.enable = true;
  };

  programs = {
    # Экран входа SilentSDDM (автоматически работает на Wayland + kwin)
    silentSDDM = {
      enable = true;
      theme = "catppuccin-mocha";
    };

    # Основная сессия Hyprland под управлением UWSM
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # Файловый менеджер Thunar и инфраструктура настроек
    dconf.enable = true;
    xfconf.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    # Декларативные расширения и политики для Google Chrome (/etc/opt/chrome/policies/managed/)
    chromium = {
      enable = true;
      extensions = [
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
        "nggfkkbmogmadfoikakkfegkoilfcfao" # Lumno (Command Bar и копирование URL)
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
        "hnafhkjheookmokbkpnfpmemlppjdgoi" # Allow Right-Click (ПКМ и копирование на любых сайтах)
      ];
      extraOpts = {
        PasswordManagerEnabled = false;
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        ExtensionSettings = {
          "nngceckbapebfimnlniiiahkandclblb" = {
            toolbar_pin = "force_pinned";
          };
          "hnafhkjheookmokbkpnfpmemlppjdgoi" = {
            toolbar_pin = "force_pinned";
          };
        };
      };
    };
  };

  # Живая Material You тема Chrome из пользовательского шаблона Caelestia (без беспарольного sudo)
  environment.etc."opt/chrome/policies/managed/caelestia.json".source =
    "/home/vyto4ka/.local/state/caelestia/theme/chrome.json";

  security = {
    polkit.enable = true;
    pam.services.sddm.enableGnomeKeyring = true;
  };

  # Автоперезапуск пользовательского агента polkit после пересборки polkit.service
  systemd.services.polkit.serviceConfig.ExecStartPost = [
    "-${pkgs.systemd}/bin/systemctl --machine=vyto4ka@.host --user try-restart hyprpolkitagent.service"
  ];

  # Явная маршрутизация XDG Desktop Portals для сессии Hyprland
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
    };
  };

  # Системные шрифты (включая все 3 шрифта Caelestia для системного /etc/fonts/fonts.conf)
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      material-symbols
      rubik
      nerd-fonts.caskaydia-cove
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      carlito
      caladea
      dejavu_fonts
    ];
    fontconfig.defaultFonts = {
      sansSerif = [
        "Rubik"
        "Noto Sans"
        "Noto Sans CJK SC"
      ];
      serif = [
        "Noto Serif"
        "Noto Serif CJK SC"
      ];
      monospace = [
        "JetBrainsMono Nerd Font"
        "CaskaydiaCove Nerd Font"
        "Noto Sans Mono"
        "Noto Sans Mono CJK SC"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
