{ config, pkgs, lib, inputs, ... }:

let
  target = pkgs.system;                            # e.g. "x86_64-linux"
  wa     = inputs.winapps.packages.${target};     # пакеты из flake winapps
in {
  nix.settings = {
    substituters        = [ "https://winapps.cachix.org/" ];
    trusted-public-keys = [ "winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g=" ];
    trusted-users       = [ "vyto4ka" ];            # ваше ЛК пользователя
  };

  environment.systemPackages = [
    wa.winapps
    wa.winapps-launcher
  ];
}