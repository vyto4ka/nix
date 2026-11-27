{ pkgs, ... }:
{
  networking = {
    networkmanager = {
      enable = true;
      plugins = [ pkgs.networkmanager-openconnect ];
    };
    # Поддержка одновременной работы двух VPN (Keqdroid TUN + Cisco AnyConnect)
    firewall.checkReversePath = "loose";
  };

  services.resolved.enable = true;

  programs.keqdroid.enable = true;
}
