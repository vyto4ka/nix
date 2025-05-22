{ config, pkgs, lib, ... }:
{
  home.file = lib.mkForce {
    ".config/kitty/kitty.conf".source         = ../../dotfiles/kitty/kitty.conf;
    ".config/kitty/current-theme.conf".source = ../../dotfiles/kitty/current-theme.conf;
  };
}
