{ pkgs, ... }:

{
  # Enable CUPS to print documents.

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    printing = {
      enable = true;
      listenAddresses = [ "*:631" ];
      allowFrom = [ "all" ];
      browsing = true;
      defaultShared = true;
      openFirewall = true;
      drivers = [ pkgs.samsung-unified-linux-driver ];
    };
  };

  hardware.printers.ensurePrinters = [
    {
      name = "SCX-4521F";
      location = "Home";
      deviceUri = "usb://Samsung/SCX-4x21%20Series?serial=8P89BAAS601808F.&interface=1";
      model = "samsung/SCX-4500.ppd";
    }
  ];

  networking.firewall = {
    allowedTCPPorts = [ 631 ];
    allowedUDPPorts = [ 631 ];
  };

}
