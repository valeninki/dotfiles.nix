{
  description = "Valen's Preferred Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, chaotic, home-manager, ... }: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
	modules = [
          ./hosts/desktop/configuration.nix
	  ./modules/external
	  chaotic.nixosModules.default

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
