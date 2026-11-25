{ lib, ... }:
let
  hasHardwareConfig = builtins.pathExists ./hardware-configuration.nix;
  hasLocalBoot = builtins.pathExists ./local-boot.nix;
in
{
  imports = [
    ./host.nix
    ../../system
  ]
  ++ lib.optional hasHardwareConfig ./hardware-configuration.nix
  ++ lib.optional hasLocalBoot ./local-boot.nix
  ++ lib.optional (!hasHardwareConfig) {
    # Заглушка для pure flake check в чистом клоне репозитория до запуска install.sh
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
  }
  ++ lib.optional (!hasLocalBoot) {
    system.stateVersion = "24.11";
    boot.loader = {
      grub.device = "nodev";
      grub.efiSupport = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
