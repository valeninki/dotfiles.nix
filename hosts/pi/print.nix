{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="232b", ATTRS{idProduct}=="a43c", ACTION=="add", MODE="0660", GROUP="lp", SYMLINK+="pantum-printer", TAG+="systemd", ENV{SYSTEMD_WANTS}="pantum-hotplug.service"
  '';

  systemd.services."container@pantum-cups".serviceConfig = {
    DevicePolicy = lib.mkForce "closed";
    DeviceAllow = [ "char-usb_device rw" ];
  };

  systemd.services.pantum-hotplug = {
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.nixos-container}/bin/nixos-container run pantum-cups -- bash -c 'systemctl restart ipp-usb.service && sleep 2 && cupsenable Pantum_P2500W'
    '';
  };

  containers.pantum-cups = {
    autoStart = true;
    privateNetwork = true;
    macvlans = [ "end0" ];

    bindMounts = {
      "/dev/bus/usb" = {
        hostPath = "/dev/bus/usb";
        isReadOnly = false;
      };
      "/run/secrets/cupsadmin-password" = {
        hostPath = config.sops.secrets."pi/berry_password".path;
        isReadOnly = true;
      };
    };

    config = { pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;

      networking.enableIPv6 = false;
      networking.interfaces."mv-end0".ipv4.addresses = [
        {
          address = "10.10.20.6";
          prefixLength = 24;
        }
      ];
      networking.defaultGateway = "10.10.20.1";
      networking.nameservers = [ "10.10.20.1" ];

      users.users.cupsadmin = {
        isNormalUser = true;
        createHome = false;
        group = "lp";
        extraGroups = [ "wheel" ];
        hashedPasswordFile = "/run/secrets/cupsadmin-password";
      };

      services.ipp-usb.enable = true;

      environment.systemPackages = [
        pkgs.cups-filters
        pkgs.kitty.terminfo
      ];

      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };

      services.printing = {
        enable = true;
        drivers = [ ];
        listenAddresses = [ "*:631" ];
        defaultShared = true;
        extraConf = ''
          ServerAlias pantum-cups pantum-cups.local 10.10.20.6 localhost 127.0.0.1
          Browsing On
          DefaultEncryption Never
          PreserveJobFiles No
          MaxJobs 100
          MaxJobsPerUser 20
          LimitRequestBody 104857600

          <Location />
            Order allow,deny
            Allow all
          </Location>

          <Location /admin>
            AuthType Default
            Require user cupsadmin
            Order deny,allow
            Deny from all
            Allow from 127.0.0.1
            Allow from 10.10.0.0/16
            Allow from 100.64.0.0/10
            Satisfy all
          </Location>

          <Location /admin/conf>
            AuthType Default
            Require user cupsadmin
            Order deny,allow
            Deny from all
            Allow from 127.0.0.1
            Allow from 10.10.0.0/16
            Allow from 100.64.0.0/10
            Satisfy all
          </Location>
        '';
      };

      hardware.printers = {
        ensurePrinters = [
          {
            name = "Pantum_P2500W";
            deviceUri = "ipp://localhost:60000/ipp/print";
            model = "everywhere";
            description = "Pantum P2500W Laser Printer";
            ppdOptions = {
              PageSize = "A4";
              media = "A4";
            };
          }
        ];
        ensureDefaultPrinter = "Pantum_P2500W";
      };

      systemd.services.ensure-printers = {
        wants = [ "ipp-usb.service" ];
        after = [ "ipp-usb.service" ];
        preStart = ''
          for i in {1..30}; do
            if (echo > /dev/tcp/127.0.0.1/60000) 2>/dev/null; then
              exit 0
            fi
            sleep 1
          done
          exit 1
        '';
      };

      systemd.sockets.cups.socketConfig.FreeBind = true;

      networking.firewall.enable = false;

      networking.nftables = {
        enable = true;
        ruleset = ''
          table inet filter {
            chain input {
              type filter hook input priority filter; policy drop;

              iif "lo" accept
              ct state established,related accept

              ip protocol icmp accept

              ip saddr { 10.10.0.0/16, 100.64.0.0/10 } tcp dport 631 accept
              ip saddr { 10.10.0.0/16, 100.64.0.0/10 } udp dport 631 accept

              ip daddr 224.0.0.251 udp dport 5353 accept
            }

            chain output {
              type filter hook output priority filter; policy drop;

              oif "lo" accept
              ct state established,related accept

              ip protocol icmp accept

              ip daddr 224.0.0.251 udp dport 5353 accept
              ip daddr 10.10.20.1 tcp dport 53 accept
              ip daddr 10.10.20.1 udp dport { 53, 123 } accept
            }
          }
        '';
      };
    };
  };
}
