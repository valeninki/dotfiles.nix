{
  config,
  lib,
  pkgs,
  valenpkgs,
  ...
}:

{
  imports = [
    ./base.nix
    ./services/stylix.nix
  ];

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_6_18;
    tmp.cleanOnBoot = true;

    kernel.sysctl = {
      "vm.swappiness" = 10;
      "net.ipv4.tcp_fin_timeout" = 30;
      "net.ipv4.tcp_max_syn_backlog" = 5000;
      "net.ipv4.tcp_rmem" = "4096 131072 12582912";
      "net.ipv4.tcp_wmem" = "4096 87380 4194304";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.netdev_max_backlog" = 2000;
      "net.core.default_qdisc" = "fq";
      "net.core.rmem_max" = 2097152;
      "net.core.wmem_max" = 2097152;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
    };
  };

  networking = {
    networkmanager.enable = false;
    useNetworkd = true;
    useDHCP = lib.mkDefault true;

    firewall = {
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
        "awg0"
      ];
    };
  };

  security = {
    polkit.enable = true;
    rtkit = {
      enable = true;
    };
  };

  hardware = {
    acpilight.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
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
      gparted
      e2fsprogs
      libva-utils
      lm_sensors
      v4l-utils
      valenpkgs.topmem
      valenpkgs.netui
      valenpkgs.zmem
    ];
  };

  services = {
    openssh.enable = true;
    scx.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;

    greetd = {
      enable = true;
      settings.default_session = {
        command =
          let
            c = config.lib.stylix.colors;
          in
          ''
            ${pkgs.tuigreet}/bin/tuigreet \
              --time \
              --asterisks \
              --user-menu \
              --greeting "Welcome back, Kerem" \
              --theme "container=#${c.base00};text=#${c.base05};border=#${c.base02};prompt=#${c.base0E};time=#${c.base03};action=#${c.base08};button=#${c.base05};input=#${c.base05}"
          '';
        user = "greeter";
      };
    };

    gnome = {
      gnome-keyring = {
        enable = true;
      };
    };
    tailscale = {
      useRoutingFeatures = "client";
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
    sway = {
      enable = true;
      xwayland.enable = true;
    };
    wireshark.enable = true;
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
    };
  };

  nix = {
    settings = {
      download-buffer-size = 134217728;
    };
  };

}
