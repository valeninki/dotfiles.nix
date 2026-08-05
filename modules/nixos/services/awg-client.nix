{
  config,
  lib,
  ...
}:

let
  cfg = config.services.awg-client;
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

  options.services.awg-client = {
    enable = lib.mkEnableOption "AmneziaWG client";

    address = lib.mkOption {
      type = lib.types.str;
      description = "Client tunnel IP address with CIDR (e.g. 10.20.51.2/32)";
    };

    privateKeySecret = lib.mkOption {
      type = lib.types.str;
      description = "SOPS secret name for the WireGuard private key";
    };

    mtu = lib.mkOption {
      type = lib.types.int;
      default = 1200;
      description = "MTU for the tunnel interface";
    };
  };

  config = lib.mkIf cfg.enable {

    sops.secrets =
      {
        ${cfg.privateKeySecret} = {
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

    boot = {
      extraModulePackages = [ config.boot.kernelPackages.amneziawg ];
      kernelModules = [ "amneziawg" ];
    };

    networking = {
      wg-quick = {
        interfaces = {
          awg0 = {
            type = "amneziawg";
            address = [ cfg.address ];
            inherit (cfg) mtu;
            privateKeyFile = config.sops.secrets.${cfg.privateKeySecret}.path;

            postUp = ''
              awg set awg0 \
                Jc "$(cat ${config.sops.secrets."amneziawg/junkPacketCount".path})" \
                Jmin "$(cat ${config.sops.secrets."amneziawg/junkPacketMinSize".path})" \
                Jmax "$(cat ${config.sops.secrets."amneziawg/junkPacketMaxSize".path})" \
                S1 "$(cat ${config.sops.secrets."amneziawg/initPacketJunkSize".path})" \
                S2 "$(cat ${config.sops.secrets."amneziawg/responsePacketJunkSize".path})" \
                H1 "$(cat ${config.sops.secrets."amneziawg/initPacketMagicHeader".path})" \
                H2 "$(cat ${config.sops.secrets."amneziawg/responsePacketMagicHeader".path})" \
                H3 "$(cat ${config.sops.secrets."amneziawg/underloadPacketMagicHeader".path})" \
                H4 "$(cat ${config.sops.secrets."amneziawg/transportPacketMagicHeader".path})"
            '';

            peers = [
              {
                publicKey = "0Js1Z2BB8GhikRes0vSk8Kr9CUYcFs6f46EymR5iyVE=";
                allowedIPs = [
                  "162.159.136.234/32"
                  "162.159.135.234/32"
                  "162.159.134.234/32"
                  "162.159.133.234/32"
                  "162.159.130.234/32"
                ];
                endpoint = "188.245.211.104:51820";
                persistentKeepalive = 25;
              }
            ];
          };
        };
      };
    };

  };

}