{
  ...
}:

{
  imports = [
    ./configuration.nix
    ./hardware.nix
    ./tailscale.nix
    (import ./disko.nix { disk = "/dev/disk/by-id/mmc-ED2S5_0x0d2567db"; })
  ];

  system.stateVersion = "26.05";
}
