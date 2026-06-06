{ ... }:
{
  imports = [
    ./configuration.nix
    ./hardware.nix
    ../../secrets
    ../../modules/nixos/disko/pi4.nix
  ];

  system.stateVersion = "25.11";
}
