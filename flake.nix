{
  description = "Valen's Compacted Flake";

  inputs = {

    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-26.05";
      flake = true;
    };

    unixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
      flake = true;
    };

    valenpkgs = {
      url = "git+https://git.valentinus.dev/valeninki/nixpkgs?ref=unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "unixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "unixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
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
        ./modules/home-manager/flake-module.nix
        inputs.pre-commit-hooks.flakeModule
      ];

      perSystem = {
        pre-commit.settings.hooks = {
          nixfmt.enable = true;
          nil.enable = true;
          deadnix.enable = true;
          statix.enable = true;
        };
      };
    };
}
