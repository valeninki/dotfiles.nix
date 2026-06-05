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
    kernelPackages = pkgs.linuxPackages_6_18;
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
    hostName = "desktop";
    hostId = "8460159f";
    networkmanager = {
      enable = true;
    };
    interfaces = {
      enp34s0 = {
        wakeOnLan = {
          enable = true;
        };
      };
    };
    firewall = {
      allowedUDPPorts = [ 9 ];
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
    font = "ter-v16b";
    keyMap = lib.mkForce "trq";
    useXkbConfig = true;
    earlySetup = true;
  };

  hardware = {
    acpilight = {
      enable = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  programs = {
    hyprland = {
      enable = true;
      xwayland = {
        enable = true;
      };
    };
    nix-ld = {
      enable = true;
    };
    fish = {
      enable = true;
    };
    wireshark = {
      enable = true;
    };
  };

  security = {
    polkit = {
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
              --asterisks \
              --user-menu \
              --greeting "Welcome back, Kerem" \
              --theme "container=#25181c;text=#e8e1df;border=#75676b;prompt=#a38a90;time=#9c8c97;action=#f06161;button=#e8e1df;input=#e8e1df"
          '';
          user = "greeter";
        };
      };
    };
  };

  stylix = {
    image = ../../assets/Wallpapers/blue_flowers.png;
    icons = {
      light = "Flat-Remix-Blue-Light";
      dark = "Flat-Remix-Blue-Dark";
    };
    cursor = {
      package = pkgs.catppuccin-cursors.mochaBlue;
      name = "catppuccin-mocha-blue-cursors";
    };
  };

  home-manager = {
    users = {
      valentinus = {
        imports = [
          ../../modules/home-manager/cli
          ../../modules/home-manager/apps
          ../../modules/home-manager/desktop
          ./home.nix
        ];
      };
    };
  };

  profiles = {
    gaming = {
      steam = {
        enable = true;
      };
    };
  };

  systemd = {
    services = {
      s5-wol-trap = {
        description = "S5 WoL Trap After AC Power Loss";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        script = ''
          sleep 600

          if loginctl list-users --no-legend | grep -q -v -E "greeter|sddm|gdm|root"; then
            echo "User active. Poweroff not triggered."
          else
            echo "No active user, going to S5 power state."
            systemctl poweroff
          fi
        '';
        serviceConfig = {
          Type = "simple";
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

  system = {
    stateVersion = "25.11";
  };

}
