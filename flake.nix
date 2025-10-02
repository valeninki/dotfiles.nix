{
  description = "Valen's Compacted Flake";

  inputs = {

    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
      flake = true;
    };

    unixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
      flake = true;
    };

    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    };

    valenpkgs = {
      url = "git+https://git.valentinus.dev/valeninki/nixpkgs.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "unixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "unixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
    };

    catppuccin = {
      url = "github:catppuccin/nix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
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
        inputs.pre-commit-hooks.flakeModule
      ];

      perSystem =
        {
          system,
          inputs',
          ...
        }:
        {
          pre-commit.settings.hooks = {
            nixfmt-rfc-style.enable = true;
            nil.enable = true;
            deadnix.enable = true;
            statix.enable = true;
          };
        };

      flake = {
        nixosModules.valentinus = import ./modules/nixos;
        homeManagerModules.valentinus = import ./modules/home-manager;
      };
    };
}
