{ inputs, ... }:

let
  repo =
    name: arch:
    (import inputs.${name} {
      system = arch;
      config.allowUnfree = true;
    });
in
{
  flake.nixosConfigurations = {
    desktop = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      pkgs = repo "nixpkgs" system;
      specialArgs = {
        unixpkgs = repo "unixpkgs" system;
        inherit inputs;
      };
      modules = [
        ./desktop
        (inputs.self + "/users/valentinus")
        inputs.home-manager.nixosModules.home-manager
        (inputs.disko.nixosModules.disko)
        (inputs.chaotic.nixosModules.nyx-cache)
        (inputs.chaotic.nixosModules.nyx-overlay)
        (inputs.chaotic.nixosModules.nyx-registry)
      ];
    };
    thinkpad = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      pkgs = repo "nixpkgs" system;
      specialArgs = {
        unixpkgs = repo "unixpkgs" system;
        inherit inputs;
      };
      modules = [
        ./thinkpad
        (inputs.self + "/users/valentinus")
        inputs.home-manager.nixosModules.home-manager
        (inputs.disko.nixosModules.disko)
        (inputs.chaotic.nixosModules.nyx-cache)
        (inputs.chaotic.nixosModules.nyx-overlay)
        (inputs.chaotic.nixosModules.nyx-registry)
      ];
    };
    minimal = inputs.nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      pkgs = repo "nixpkgs" system;
      specialArgs = {
        unixpkgs = repo "unixpkgs" system;
        inherit inputs;
      };
      modules = [
        ./minimal
        (inputs.self + "/users/test")
        inputs.home-manager.nixosModules.home-manager
        (inputs.disko.nixosModules.disko)
      ];
    };
    pi = inputs.nixpkgs.lib.nixosSystem rec {
      system = "aarch64-linux";
      pkgs = repo "nixpkgs" system;
      specialArgs = {
        unixpkgs = repo "unixpkgs" system;
        inherit inputs;
      };
      modules = [
        ./pi
        (inputs.self + "/users/berry")
        inputs.home-manager.nixosModules.home-manager
      ];
    };

  };

  flake.homeConfigurations = {
    desktop = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = repo "nixpkgs" "x86_64-linux";
      extraSpecialArgs = {
        inherit inputs;
        unixpkgs = repo "unixpkgs" "x86_64-linux";
      };
      modules = [
        ./desktop/home
        (inputs.self + "/users/valentinus/home")
      ];
    };
    thinkpad = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = repo "nixpkgs" "x86_64-linux";
      extraSpecialArgs = {
        inherit inputs;
        unixpkgs = repo "unixpkgs" "x86_64-linux";
      };
      modules = [
        ./thinkpad/home
        (inputs.self + "/users/valentinus/home")
      ];
    };
    minimal = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = repo "nixpkgs" "x86_64-linux";
      extraSpecialArgs = {
        inherit inputs;
        unixpkgs = repo "unixpkgs" "x86_64-linux";
      };
      modules = [
        ./minimal/home
        (inputs.self + "/users/test/home")
      ];
    };
    pi = inputs.homeManagerConfiguration {
      pkgs = repo "nixpkgs" "aarch64-linux";
      extraSpecialArgs = {
        inherit inputs;
        unixpkgs = repo "unixpkgs" "aarch64-linux";
      };
      modules = [
        ./pi/home
        (inputs.self + "/users/berry/home")
      ];
    };
  };
}
