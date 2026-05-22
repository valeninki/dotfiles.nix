{
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
            JunkPacketCount = 9;
            JunkPacketMinSize = 90;
            JunkPacketMaxSize = 685;
            InitPacketJunkSize = 109;
            ResponsePacketJunkSize = 123;
            InitPacketMagicHeader = 930942820;
            ResponsePacketMagicHeader = 932360443;
            UnderloadPacketMagicHeader = 1845528299;
            TransportPacketMagicHeader = 1220663050;

            ListenPort = 51820;
            PrivateKeyFile = "/home/valen/keys/amneziawg/private";
          };
          wireguardPeers = [
            {
              wireguardPeerConfig = {
                PublicKey = "j5vprUeeYy/v6b8jS1+ruGA+5cCUhXDzkFh9O1BW91w=";
                AllowedIps = [ "10.20.51.2/32" ];
              };
            }
            {
              wireguardPeerConfig = {
                PublicKey = "PScE2fipEKe4GHmjWYt8Rha6IhXiPXY8+dZHzjQrKEw=";
                AllowedIps = [ "10.20.51.3/32" ];
              };
            }
            {
              wireguardPeerConfig = {
                PublicKey = "+5ZjBfZuGBM9rkhU79tdlv5jG25VEk0gq1UA9Jdc42U=";
                AllowedIps = [ "10.20.51.4/32" ];
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
  };

}
