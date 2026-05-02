{
  networking = {
    nftables = {
      enable = true;
    };
    firewall = {
      enable = true;
      trustedInterfaces = [
        "tailscale0"
        "awg0"
      ];
    };
  };
}
