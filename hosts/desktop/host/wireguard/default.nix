{ pkgs, config, ... }:

{
  networking = {
    wireguard = {
      interfaces = {
        wg0 = {
          ips = [ "10.0.0.2/32" ];
          listenPort = 51820;
          privateKeyFile = "/home/valentinus/Nextcloud/Wireguard/desktop/private";

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
}
