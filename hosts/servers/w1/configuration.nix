# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  lib,
  pkgs,
  ...
}:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_6_12;
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };

  networking = {
    hostName = "w1";
    networkmanager = {
      enable = true;
    };
  };

  time = {
    timeZone = "Europe/Istanbul";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    packages = [ pkgs.terminus_font ];
    font = "ter-v16b";
    keyMap = lib.mkForce "trq";
    useXkbConfig = true;
    earlySetup = true;
  };

  programs = {
    ssh = {
      startAgent = false;
    };
    nix-ld = {
      enable = true;
    };
    fish = {
      enable = true;
    };
    wireshark = {
      enable = true;
    };
  };

  services = {
    openssh = {
      enable = true;
    };
    scx = {
      enable = true;
      scheduler = "scx_rusty";
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system = {
    stateVersion = "25.11";
  };

}
