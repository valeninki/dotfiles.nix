{
  description = "Valen's Preferred Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    valenpkgs.url = "git+https://git.valentinus.dev/valeninki/nixpkgs.git";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { nixpkgs, unixpkgs, chaotic, home-manager, ... }:
    let
    system = "x86_64-linux";
    overlay-unstable = final: prev: {
      unstable = unixpkgs.legacyPackages.${prev.system};
    };
    in {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
      inherit system;
	  
	modules = [
	  ({  config, pkgs, ...}: {nixpkgs.overlays = [ overlay-unstable ]; })
          ./hosts/desktop/configuration.nix
	 # ./modules/external
	  chaotic.nixosModules.nyx-cache
	  chaotic.nixosModules.nyx-overlay
	  chaotic.nixosModules.nyx-registry

           home-manager.nixosModules.home-manager {
             home-manager.useGlobalPkgs = true;
	     home-manager.useUserPackages = true;
	     home-manager.users.valentinus = ./hosts/desktop/home.nix;
	   }
	 ];
      };
    };
  };
}
