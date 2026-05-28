{
  inputs,
  ...
}:

let
  repo =
    name: arch:
    (import inputs.${name} {
      system = arch;
      config.allowUnfree = true;
    });
in
{

  flake = {
    nixosConfigurations = {

      desktop = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          unixpkgs = repo "unixpkgs" system;
          inherit inputs;
        };
        modules = [
          {
            nixpkgs.pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
          ./desktop
          ../modules/nixos/base-desktop.nix
          ../modules/nixos/valenpkgs.nix
          ../modules/nixos/gaming
          (inputs.self + "/users/valentinus")
          inputs.home-manager.nixosModules.home-manager
          inputs.disko.nixosModules.disko
          inputs.chaotic.nixosModules.nyx-cache
          inputs.chaotic.nixosModules.nyx-overlay
          inputs.chaotic.nixosModules.nyx-registry
        ];
      };

      thinkpad = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          unixpkgs = repo "unixpkgs" system;
          inherit inputs;
        };
        modules = [
          {
            nixpkgs.pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
          ./thinkpad
          ../modules/nixos/base-desktop.nix
          ../modules/nixos/valenpkgs.nix
          (inputs.self + "/users/valentinus")
          inputs.home-manager.nixosModules.home-manager
          inputs.disko.nixosModules.disko
          inputs.chaotic.nixosModules.nyx-cache
          inputs.chaotic.nixosModules.nyx-overlay
          inputs.chaotic.nixosModules.nyx-registry
        ];
      };

      m1 = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          unixpkgs = repo "unixpkgs" system;
          inherit inputs;
        };
        modules = [
          { nixpkgs.pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux"; }
          ../users/zen
          ./servers/m1
        ];
      };

      w1 = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          unixpkgs = repo "unixpkgs" system;
          inherit inputs;
        };
        modules = [
          { nixpkgs.pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux"; }
          ../users/zen
          ./servers/w1
        ];
      };

      w2 = inputs.nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          unixpkgs = repo "unixpkgs" system;
          inherit inputs;
        };
        modules = [
          { nixpkgs.pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux"; }
          ../users/zen
          ./servers/w2
        ];
      };

      pi = inputs.nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        specialArgs = {
          unixpkgs = repo "unixpkgs" system;
          inherit inputs;
        };
        modules = [
          { nixpkgs.pkgs = inputs.nixpkgs.legacyPackages."aarch64-linux"; }
          ./pi
          inputs.self.nixosModules.berry
        ];
      };
    };
  };

}
