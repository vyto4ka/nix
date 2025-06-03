{
  description = "NixOS config by vyto4ka";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.vyt = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          # ./modules/winapps.nix 
          ./modules/virtualization.nix
        ];
        specialArgs = { inherit inputs; };
      };
    };
}