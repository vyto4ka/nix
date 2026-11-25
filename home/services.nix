{
  # Запускает nm-applet с флагом --indicator (StatusNotifierItem) для трея Quickshell/Caelestia
  # и встроенного окна SSO / паролей Cisco AnyConnect
  xsession.preferStatusNotifierItems = true;

  services = {
    hyprpolkitagent.enable = true;
    network-manager-applet.enable = true;
    kdeconnect = {
      enable = true;
      indicator = true;
    };
  };
}
