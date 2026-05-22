{
  config,
  pkgs,
  ...
}:

{

  environment = {
    systemPackages = with pkgs; [
	  amneziawg-tools
	];
  };

  boot = {
    extraModulePackages = [ config.boot.kernelPackages.amneziawg ];
	kernelModules = [
	  "amneziawg";
	];
	kernel = {
	  sysctl = {
	    "net.ipv4.ip_forward" = 1;
	  };
	};
  };

  sops = {
    secrets = {
	  "amneziawg/w2_private_key" = {};
	};
  };

  networking = {
    nat = {
	  enable = true;
	  externalInterface = "eth0";
	  internalInterfaces = [
	    "awg0"
	  ];
	};
	firewall = {
	  allowedUDPPorts = [
	    51820
	  ];
	};
	wg-quick = {
	  interfaces = {
	    awg0 = {
		  type = "amneziawg";
		  address = [ "10.20.51.1/24" ];
		  listenPort = 51820;
		  privateKeyFile = config.sops.secrets."amneziawg/w2_private_key".path;
          
		  extraOptions = {
            Jc = 9;
            Jmin = 90;
            Jmax = 685;
            S1 = 109;
            S2 = 123;
            H1 = 930942820;
            H2 = 932360443;
            H3 = 1845528299;
            H4 = 1220663050;
          };

		  peers = [
		    {
			  publicKey = "j5vprUeeYy/v6b8jS1+ruGA+5cCUhXDzkFh9O1BW91w=";
			  allowedIPs = [ "10.20.51.2/32" ];
			}
			{
			  publicKey = "PScE2fipEKe4GHmjWYt8Rha6IhXiPXY8+dZHzjQrKEw=";
			  allowedIPs = [ "10.20.51.3/32" ];
			}
			{
			  publicKey = "+5ZjBfZuGBM9rkhU79tdlv5jG25VEk0gq1UA9Jdc42U=";
			  allowedIPs = [ "10.20.51.4/32" ];
			}
			{
			  publicKey = "IRgC2KD2fs43ZgNpUQuO6E0GFixzcftfcPWwS/gh5kY=";
			  allowedIPs = [ "10.20.51.5/32" ];
			}
		  ];

		};
	  };
	};
  };

}
