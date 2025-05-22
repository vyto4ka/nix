{ config, pkgs, lib, ... }:

{
  virtualisation.docker.enable  = true;
  boot.kernelModules = [ "kvm" "kvm-intel" ];  
  boot.extraModprobeConfig = ''
    options kvm-intel nested=1
  '' ;
  virtualisation.libvirtd.enable = true;

  virtualisation.docker.package = pkgs.docker;
  users.users.vyto4ka = {
    extraGroups = [ "docker" "kvm" "libvirtd" ];
  };

  environment.systemPackages = [
    pkgs.docker
    pkgs.docker-compose
  ];
}