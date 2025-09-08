{
  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
  enable = true;
  nssmdns4 = true;
  openFirewall = true;
};

  services.printing = {
  listenAddresses = [ "*:631" ];
  allowFrom = [ "all" ];
  browsing = true;
  defaultShared = true;
  openFirewall = true;
};

networking.firewall = {
  allowedTCPPorts = [ 631 ];
  allowedUDPPorts = [ 631 ];
};

}
