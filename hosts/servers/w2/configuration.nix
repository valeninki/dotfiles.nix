# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  lib,
  pkgs,
  ...
}:

{
  # Evaluation fallback until this host has a real root filesystem definition.
  # A deployment must replace this with the actual filesystem configuration.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/null";
    fsType = "ext4";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_6_18;
  };

  networking.hostName = "w2";

  services.scx.scheduler = "scx_bpfland";

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

}
