{
  description = "NixOS configuration for Zenbook with Hyprland and Caelestia";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-dots = {
      url = "github:caelestia-dots/caelestia";
      flake = false;
    };

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    keqdroid = {
      url = "github:Lemonochka/keqdroid/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    vysh = {
      url = "github:vyto4ka/vysh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixowos = {
      url = "github:yunfachi/nixowos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      configDir = "/home/vyto4ka/nixos-config";
    in
    {
      formatter.${system} = pkgs.nixfmt;

      nixosConfigurations.zenbook = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs configDir;
        };
        modules = [
          ./hosts/zenbook
          inputs.keqdroid.nixosModules.default
          inputs.silentSDDM.nixosModules.default
          inputs.nix-index-database.nixosModules.nix-index
          inputs.nixowos.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-bak";
              extraSpecialArgs = {
                inherit inputs configDir;
              };
              users.vyto4ka = import ./home;
            };
          }
        ];
      };

      checks.${system} = {
        zenbook-eval = pkgs.writeText "zenbook-toplevel-drv" (
          builtins.unsafeDiscardStringContext self.nixosConfigurations.zenbook.config.system.build.toplevel.drvPath
        );
        caelestia-dots-nixos =
          let
            hmCfg = self.nixosConfigurations.zenbook.config.home-manager.users.vyto4ka;
            execsLua = hmCfg.xdg.configFile."hypr/hyprland/execs.lua".source;
          in
          pkgs.runCommand "check-caelestia-dots-nixos" { } ''
            ! grep -Fq "caelestia shell -d" "${execsLua}"
            ! grep -Fq "/usr/lib/polkit-gnome/" "${execsLua}"
            ! grep -Fq "/usr/lib/geoclue-2.0/" "${execsLua}"
            cp "${execsLua}" "$out"
          '';
      };
    };
}
