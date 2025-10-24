{

  networking = {
    nftables = {
      enable = true;
    };
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
        "tailscale0"
      ];
    };
  };

}
