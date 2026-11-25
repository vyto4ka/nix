{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    vendor = {
      config.enable = true;
      completions.enable = true;
      functions.enable = true;
    };
    interactiveShellInit = ''
      set -gx EDITOR nvim
    '';
  };

  environment.variables.EDITOR = "nvim";

  users.users.vyto4ka = {
    isNormalUser = true;
    home = "/home/vyto4ka";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "input"
      "audio"
      "video"
    ];
  };
}
