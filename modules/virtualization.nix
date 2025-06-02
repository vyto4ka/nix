{ config, pkgs, lib, ... }:

{
  #  VirtualBox 
  services.virtualisation.virtualbox.host.enable = true;
  boot.kernelModules = [ "vboxdrv" ];
  users.users.vyto4ka.extraGroups = [ "vboxusers" ];

  # Docker+KVM 
  # virtualisation.docker.enable  = true;
  # boot.kernelModules             = [ "kvm" "kvm-intel" ];
  # boot.extraModprobeConfig       = ''
  #   options kvm-intel nested=1
  # '';
  # virtualisation.libvirtd.enable = true;
  # users.users.vyto4ka.extraGroups = [ "docker" "kvm" "libvirtd" ];
  # virtualisation.docker.package = pkgs.docker;

  # environment.systemPackages = [
  #   pkgs.docker
  #   pkgs.docker-compose
  # ];
}
