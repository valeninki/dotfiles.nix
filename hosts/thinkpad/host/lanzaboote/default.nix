{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];
  
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
