{
  ...
}:

{
  imports = [
    ./configuration.nix
    ./hardware.nix
    ./tailscale.nix
    ../../secrets
    ../../modules/nixos/disko/pi4.nix
  ];

  system.stateVersion = "26.05";
}
