{ unixpkgs, ... }:

{
  services.tailscale = {
    enable = true;
    package = unixpkgs.tailscale;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--accept-dns"
      "--accept-router"
      "--ssh"
    ];
  };
}
