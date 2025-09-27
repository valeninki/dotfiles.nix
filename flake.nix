{
  description = "Valen's Compacted Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    disko.url = "github:nix-community/disko/latest";

    valenpkgs.url = "git+https://git.valentinus.dev/valeninki/nixpkgs.git";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "unixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    home-manager-unstable = {
      url = "github:nix-community/home-manager"
      inputs.nixpkgs.follows = "unixpkgs";
    };

  };

  outputs =
  inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    
    imports = [
      ./hosts/flake-module.nix
    ];

    perSystem = 
      {
        system,
	inputs',
	...
      };
      {
        pre-commit.settings.hooks = {
          nixfmt-rfc-style.enable = true;
	  nil.enable = true;
	  deadnix.enable = true;
	  statix.enable = true;
	};
      };

      flake = {
        nixosModules.valentinus = import ./modules/nixos
	homeManagerModules.valentinus = import ./modules/home-manager
      };
  };
}
