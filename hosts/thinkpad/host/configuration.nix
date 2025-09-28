# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, valenpkgs, inputs, ... }:

{
  # Uses latest CachyOS kernel and enables "scx_bpfland" scheduler.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.scx = {
    enable = true;
    scheduler = "scx_bpfland";
  };

  # Enables flake and nd.
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; 
  programs.nix-ld.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
  };

  # Network settings.
  networking = {
    hostName = "thinkpad"; # Define your hostname.
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "trq";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  programs = {
    hyprland.enable = true;
  };

  # Enable AMD Graphics and enable 32Bit.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [amdvlk];
    extraPackages32 = with pkgs; [driversi686Linux.amdvlk];
  };

  programs = {
    fish.enable = true;
    neovim.enable = true;
    wireshark.enable = true;
  };

  environment.systemPackages = with pkgs; 
       [
        wget
        networkmanagerapplet
        gparted
        e2fsprogs
        duperemove
	dmidecode
       ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system.stateVersion = "25.05";

}

