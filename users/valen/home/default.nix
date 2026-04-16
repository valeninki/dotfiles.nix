{
  lib,
  pkgs,
  ...
}:

{
  home = {
    stateVersion = "25.11";

    activation = { };

    packages = with pkgs; [

      ## Must Need Packages
      git
      unzip

      ## Monitoring Packages
      fastfetch
      htop
      btop
      gping

      ## Network Things
      ethtool
      nmap
      traceroute
      bind
      tcpdump
      mtr
    ];
  };

  imports =
    lib.map (p: ./. + "/${p}") (lib.remove "default.nix" (lib.attrNames (builtins.readDir ./.)))
    ++ [ ../../../modules/home-manager/x86_64-linux/servers ];
}
