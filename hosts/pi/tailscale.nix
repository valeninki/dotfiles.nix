{
  services = {
    networkd-dispatcher = {
      enable = true;
      rules."50-tailscale" = {
        onState = [ "routable" ];
        script = ''
          ethtool -K end0 rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };
  };
}
