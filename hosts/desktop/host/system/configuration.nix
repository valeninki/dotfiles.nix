# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  lib,
  pkgs,
  ...
}:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_6_12;
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };

  networking = {
    hostName = "nixos";
	hostId = "8460159f";
    networkmanager = {
      enable = true;
    };
  };

  time = {
    timeZone = "Europe/Istanbul";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    packages = [ pkgs.terminus_font ];
    font = "terv16b";
    keyMap = lib.mkForce "trq";
    useXkbConfig = true; # use xkb.options in tty.
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  programs = {
    ssh = {
      startAgent = true;
    };
    hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
    };
    nix-ld = {
      enable = true;
    };
    light = {
      enable = true;
    };
    fish = {
      enable = true;
    };
    wireshark = {
      enable = true;
    };
  };

  services = {
    openssh = {
      enable = true;
    };
    scx = {
      enable = true;
      scheduler = "scx_bpfland";
    };

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = ''
            		    ${pkgs.tuigreet}/bin/tuigreet \
            			--time \
            			--asterisks
            			--user-menu
            			--greeting "Welcome back, Kerem" \
            			--theme "container=#25181c;text=#e8e1df;border=#75676b;prompt=#a38a90;time=#9c8c97;action=#f06161;button=#e8e1df;input=#e8e1df"
            		  '';
          user = "greeter";
        };
      };
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system = {
    stateVersion = "25.11";
  };

}
