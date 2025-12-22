{
  description = "NixOS config by vyto4ka";

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
  };

  outputs = { self, nixpkgs, home-manager, caelestia-shell, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.vyt = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./configuration.nix
        ./modules/virtualization.nix

        home-manager.nixosModules.home-manager
        caelestia-shell.homeManagerModules.default

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = {
            inherit caelestia-shell;
          };

          home-manager.users.vyto4ka = import ./home.nix;
        }
      ];
    };
  };
}