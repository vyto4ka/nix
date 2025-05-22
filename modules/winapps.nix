{ config, pkgs, lib, inputs, ... }:

let
  target = pkgs.system;
  wa     = inputs.winapps.packages.${target};
in {
  nix.settings = {
    substituters        = [ "https://winapps.cachix.org/" ];
    trusted-public-keys = [ "winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g=" ];
    trusted-users       = [ "vyto4ka" ];
  };

  environment.systemPackages = [
    wa.winapps
    wa.winapps-launcher
  ];
}