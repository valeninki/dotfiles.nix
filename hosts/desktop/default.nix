{
  inputs,
  ...
}:

{

  imports = [
    ./configuration.nix
    ./hardware.nix
    ./awg.nix
    ../../modules/nixos/disko/zfs.nix
  ];

  system.stateVersion = "25.11";

}
