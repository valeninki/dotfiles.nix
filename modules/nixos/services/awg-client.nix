{
  config,
  ...
}:

{

  boot = {
    extraModulePackages = [
	  config.boot.kernelPackages.amneziawg
	];
	kernelModules = [
	  "amneziawg"
	];
  };

  networking = {
    wg-quick = {
	  interfaces = {
	    awg0 = {
		  type = "amneziawg";

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
