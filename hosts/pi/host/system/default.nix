{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    duperemove
    ethtool
    networkd-dispatcher
    wakeonlan
  ];
}
