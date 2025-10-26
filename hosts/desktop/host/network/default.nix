{
  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    interfaces = {
      enp34s0 = {
        wakeOnLan.enable = true;
      };
    };
  };
}
