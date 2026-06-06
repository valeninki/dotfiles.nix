{ pkgs, lib, ... }:
{
  boot = {
    loader = {
      timeout = 1;
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  networking = {
    hostName = "pi";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    packages = [ pkgs.terminus_font ];
    font = "ter-v16b";
    keyMap = lib.mkForce "trq";
    useXkbConfig = true;
    earlySetup = true;
  };

  users.users.berry = {
    isNormalUser = true;
    home = "/home/berry";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  security.doas.enable = true;

  environment.systemPackages = with pkgs; [ git wget ethtool ];

  programs = {
    nix-ld.enable = true;
    fish.enable = true;
  };

  services = {
    openssh.enable = true;
    s3.enable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";
}
