{ pkgs, inputs, ... }:
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

  environment.systemPackages = [
    inputs.keqdroid.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
