{
  lib,
  pkgs,
  unixpkgs,
  ...
}:

{
  time.timeZone = "Europe/Istanbul";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    packages = [ pkgs.terminus_font ];
    font = "ter-v16b";
    keyMap = lib.mkForce "trq";
    earlySetup = true;
  };

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
      wget
      dmidecode
      duperemove
    ];
  };

  programs = {
    fish.enable = true;
    nix-ld.enable = true;
  };

  services = {
    resolved = {
      enable = true;
      settings = {
        Resolve = {
          DNS = [
            "9.9.9.9#dns.quad9.net"
            "149.112.112.112#dns.quad9.net"
          ];
          DNSOverTLS = "true";
          DNSSEC = "true";
          Domains = [ "~." ];
          FallbackDNS = [
            "9.9.9.9#dns.quad9.net"
            "149.112.112.112#dns.quad9.net"
          ];
        };
      };
    };
    tailscale = {
      enable = true;
      package = unixpkgs.tailscale;
      extraUpFlags = [
        "--accept-dns"
        "--ssh"
      ];
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
