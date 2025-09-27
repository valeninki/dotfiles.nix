{ inputs, ... }:

let
  repo = 
    name: arch:
    (import inputs.${name} {
      system = arch;
      config.allowUnfree = true;
    });
{
  flake.nixosConfigurations = {
    desktop = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      pkgs = repo "nixpkgs" system;
      specialArgs = {
        unixpkgs = repo "unixpkgs" system;
	inherit inputs;
      };
      modules = [
        ./desktop
	(inputs.self + "/users/valentinus")
	disko.nixosModules.disko
	chaotic.nixosModules.nyx-cache
	chaotic.nixosModules.nyx-overlay
	chaotic.nixosModules.nyx-registry
      ];
    };
    thinkpad = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      pkgs = repo "nixpkgs" system;
      specialArgs = {
        unixpkgs = repo "unixpkgs" system;
        inherit inputs;
      };
      modules = [
        ./thinkpad
	(inputs.self + "/users/valentinus")
	disko.nixosModules.disko
	chaotic.nixosModules.nyx-cache
	chaotic.nixosModules.nyx-overlay
	chaotic.nixosModules.nyx-registry
      ];
    };
    minimal = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      pkgs = repo "nixpkgs" system;
      specialArgs = {
        unixpkgs = repo "unixpkgs" system;
	inherit inputs;
      };
      modules = [
        ./minimal
      ];
    };
  };

  flake.homeConfigurations = {
    desktop = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = repo "nixpkgs" "x86_64-linux";
      extraSpecialArgs = {
        inherit inputs;
	unixpkgs = repo "unixpkgs" "x86_64-linux"
      };
      modules = [
        ./thinkpad/home
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
	("/users/test/home")
      ];
    };
  };
}
