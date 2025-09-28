{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    boot.loader.systemd-boot.enable = lib.mkForce false;
    environment.systemPackages = [
      pkgs.sbctl
    ];
  };
}
