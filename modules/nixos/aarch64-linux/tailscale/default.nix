{ unixpkgs, ... }:

{
  services.tailscale = {
    enable = true;
    package = unixpkgs.tailscale;
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--accept-dns"
      "--accept-router"
      "--ssh"
    ];
  };
}
