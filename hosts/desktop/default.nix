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
    ../../modules/nixos/services/awg-client.nix
    ../../secrets
  ];

  system.stateVersion = "25.11";

}
