{ config, pkgs, lib, ... }:
{
  home.file = lib.mkForce {
    ".config/neofetch/config.conf".source = ../../dotfiles/neofetch/config.conf;
    ".config/fastfetch/config.jsonc".source = ../../dotfiles/fastfetch/config.jsonc;
  };
}
