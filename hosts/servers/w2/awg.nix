{
  config,
  pkgs,
  ...
}:

let
  awgParams = [
    "junkPacketCount"
    "junkPacketMinSize"
    "junkPacketMaxSize"
    "initPacketJunkSize"
    "responsePacketJunkSize"
    "initPacketMagicHeader"
    "responsePacketMagicHeader"
    "underloadPacketMagicHeader"
    "transportPacketMagicHeader"
  ];
in
{
  imports = [
    ../../../secrets
  ];

  boot.kernelModules = [ "amneziawg" ];

  sops.secrets =
    {
      "amneziawg/w2_private_key" = {
        mode = "0400";
      };
    }
    // builtins.listToAttrs (
      map (name: {
        name = "amneziawg/${name}";
        value = {
          sopsFile = ../../../secrets/host-secrets.yaml;
          mode = "0400";
        };
      }) awgParams
    );

  systemd = {
    network = {
      enable = true;

      netdevs = {
        "10-awg0" = {
          netdevConfig = {
            Kind = "amneziawg";
            Name = "awg0";
          };

          amneziaWGConfig = {
            ListenPort = 51820;
            PrivateKeyFile = config.sops.secrets."amneziawg/w2_private_key".path;
          };

          wireguardPeers = [
            {
              wireguardPeerConfig = {
                PublicKey = "j5vprUeeYy/v6b8jS1+ruGA+5cCUhXDzkFh9O1BW91w=";
                AllowedIPs = [ "10.20.51.2/32" ];
              };
            }
            {
              wireguardPeerConfig = {
                PublicKey = "PScE2fipEKe4GHmjWYt8Rha6IhXiPXY8+dZHzjQrKEw=";
                AllowedIPs = [ "10.20.51.3/32" ];
              };
            }
            {
              wireguardPeerConfig = {
                PublicKey = "+5ZjBfZuGBM9rkhU79tdlv5jG25VEk0gq1UA9Jdc42U=";
                AllowedIPs = [ "10.20.51.4/32" ];
              };
            }
            {
              wireguardPeerConfig = {
                PublicKey = "IRgC2KD2fs43ZgNpUQuO6E0GFixzcftfcPWwS/gh5kY=";
                AllowedIPs = [ "10.20.51.5/32" ];
              };
            }
          ];
        };
      };
    };

    services.awg-server-params = {
      description = "Apply AmneziaWG obfuscation parameters from SOPS";
      after = [ "sys-subsystem-net-devices-awg0.device" ];
      wants = [ "sys-subsystem-net-devices-awg0.device" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = [ pkgs.amneziawg-tools ];
      script = ''
        awg set awg0 \
          jc "$(cat ${config.sops.secrets."amneziawg/junkPacketCount".path})" \
          jmin "$(cat ${config.sops.secrets."amneziawg/junkPacketMinSize".path})" \
          jmax "$(cat ${config.sops.secrets."amneziawg/junkPacketMaxSize".path})" \
          s1 "$(cat ${config.sops.secrets."amneziawg/initPacketJunkSize".path})" \
          s2 "$(cat ${config.sops.secrets."amneziawg/responsePacketJunkSize".path})" \
          h1 "$(cat ${config.sops.secrets."amneziawg/initPacketMagicHeader".path})" \
          h2 "$(cat ${config.sops.secrets."amneziawg/responsePacketMagicHeader".path})" \
          h3 "$(cat ${config.sops.secrets."amneziawg/underloadPacketMagicHeader".path})" \
          h4 "$(cat ${config.sops.secrets."amneziawg/transportPacketMagicHeader".path})"
      '';
    };
  };
}