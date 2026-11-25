{ pkgs, ... }:
let
  appimageRunPortal = pkgs.writeShellScriptBin "appimage-run" ''
    export GTK_USE_PORTAL=1
    export NIXOS_XDG_OPEN_USE_PORTAL=1
    exec ${pkgs.appimage-run}/bin/appimage-run "$@"
  '';
in
{
  # programs.appimage.enable намеренно не включаем: используем FUSE + тонкий шим с порталами
  programs.fuse.enable = true;

  environment.systemPackages = [
    appimageRunPortal
  ];
}
