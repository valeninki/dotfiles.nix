# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  pkgs,
  ...
}:

{
  boot = {
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

  services.scx.scheduler = "scx_bpfland";

  stylix = {
    image = ../../assets/Wallpapers/flowers.jpg;
    cursor = {
      package = pkgs.catppuccin-cursors.frappeYellow;
      name = "catppuccin-frappe-yellow-cursors";
    };
  };

  home-manager = {
    users = {
      valentinus = {
        imports = [
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

}
