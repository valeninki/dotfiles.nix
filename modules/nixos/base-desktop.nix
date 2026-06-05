{
  inputs,
  pkgs,
  unixpkgs,
  valenpkgs,
  ...
}:

{
  imports = [
    ./services/stylix.nix
  ];

  networking = {
    nftables = {
      enable = true;
    };
    nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];
    firewall = {
      enable = true;
      allowedUDPPorts = [ 51820 ];
      allowedUDPPortRanges = [
        {
          from = 4000;
          to = 4007;
        }
        {
          from = 8000;
          to = 8010;
        }
        {
          from = 49152;
          to = 65535;
        }
      ];
      trustedInterfaces = [
        "virbr0"
        "tailscale0"
        "awg0"
      ];
    };
  };

  security = {
    sudo = {
      enable = false;
    };
    doas = {
      enable = true;
    };
    rtkit = {
      enable = true;
    };
  };

  users = {
    groups = {
      libvirtd = {
        members = [
          "valentinus"
        ];
      };
    };
  };

  systemd = {
    services = {
      libvirtd = {
        path = [ pkgs.nftables ];
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      git
      wget
      networkmanagerapplet
      gparted
      e2fsprogs
      duperemove
      dmidecode
      libva-utils
      lm_sensors
      v4l-utils
      valenpkgs.topmem
      valenpkgs.zmem
    ];
  };

  services = {
    resolved = {
      enable = true;
      settings = {
        Resolve = {
          DNS = [
            "9.9.9.9#dns.quad9.net"
            "149.112.112.112#dns.quad9.net"
          ];
          DNSOverTLS = "true";
          DNSSEC = "true";
          Domains = [ "~." ];
          FallbackDNS = [
            "9.9.9.9#dns.quad9.net"
            "149.112.112.112#dns.quad9.net"
          ];
        };
      };
    };
    gnome = {
      gnome-keyring = {
        enable = true;
      };
    };
    tailscale = {
      enable = true;
      package = unixpkgs.tailscale;
      useRoutingFeatures = "client";
      extraUpFlags = [
        "--accept-dns"
        "--ssh"
      ];
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse = {
        enable = true;
      };
      jack = {
        enable = true;
      };
    };
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
  };

  programs = {
    virt-manager = {
      enable = true;
    };
  };

  virtualisation = {
    libvirtd = {
      enable = true;
    };
    spiceUSBRedirection = {
      enable = true;
    };
  };

  xdg = {
    autostart = {
      enable = true;
    };
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = "*";
        };
      };
    };
  };

  nix = {
    settings = {
      download-buffer-size = 134217728;
    };
  };

}
