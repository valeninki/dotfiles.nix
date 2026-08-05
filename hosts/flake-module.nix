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

  mkHost =
    {
      name,
      system ? "x86_64-linux",
      modules,
      nixpkgsConfig ? { },
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        unixpkgs = repo "unixpkgs" system;
        inherit inputs;
      };
      modules = [
        {
          nixpkgs.pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            }
            // nixpkgsConfig;
          };
        }
        ./${name}
      ]
      ++ modules;
    };

  mkDesktopHost =
    {
      name,
      gaming ? false,
    }:
    mkHost {
      inherit name;
      modules = [
        ../modules/nixos/base-desktop.nix
        ../modules/nixos/valenpkgs.nix
      ]
      ++ inputs.nixpkgs.lib.optional gaming ../modules/nixos/gaming
      ++ [
        (inputs.self + "/users/valentinus")
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
      ];
    };

  mkVmServerHost =
    { name }:
    mkHost {
      inherit name;
      modules = [
        (inputs.self + "/users/zen")
        ../modules/nixos/base-vm-server.nix
      ];
    };
in
{
  flake = {
    nixosConfigurations = {
      desktop = mkDesktopHost {
        name = "desktop";
        gaming = true;
      };

      thinkpad = mkDesktopHost {
        name = "thinkpad";
      };

      m1 = mkVmServerHost {
        name = "servers/m1";
      };

      w1 = mkVmServerHost {
        name = "servers/w1";
      };

      w2 = mkVmServerHost {
        name = "servers/w2";
      };

      pi = mkHost {
        system = "aarch64-linux";
        name = "pi";
        nixpkgsConfig.permittedInsecurePackages = [ "pnpm-9.15.9" ];
        modules = [
          inputs.nixos-hardware.nixosModules.raspberry-pi-4
          inputs.disko.nixosModules.disko
          ../modules/nixos/base-server.nix
          ../modules/nixos/services/garage.nix
        ];
      };
    };
  };
}
