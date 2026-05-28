{
  inputs,
  pkgs,
  unixpkgs,
  ...
}:

{

  networking = {
    nftables = {
      enable = true;
    };
    nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];
    firewall = {
      enable = true;
      trustedInterfaces = [
        "tailscale0"
      ];
    };
  };

  security = {
    sudo = {
      enable = false;
    };
    doas = {
      enable = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      curl
      wget
      duperemove
      dmidecode
      iperf3
    ];
  };

  services = {
    resolved = {
      enable = true;
      dnssec = "true";
      dnsovertls = "true";
      domains = [ "~." ];
      fallbackDns = [
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
      ];
    };
    tailscale = {
      enable = true;
      package = unixpkgs.tailscale;
      useRoutingFeatures = "server";
      extraUpFlags = [
        "--accept-dns"
        "--ssh"
      ];
    };
  };

}
