{ configDir, ... }:
{
  networking.hostName = "zenbook";
  nixowos.enable = true;

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowUnfree = true;
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "vyto4ka"
      ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  programs = {
    nh = {
      enable = true;
      flake = configDir;
    };
    nix-index-database.comma.enable = true;
  };
}
