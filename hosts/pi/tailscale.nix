{
  services = {
    networkd-dispatcher = {
      enable = true;
      rules."50-tailscale" = {
        onState = [ "routable" ];
        script = ''
          ethtool -K "$IFACE" rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };
  };
}
