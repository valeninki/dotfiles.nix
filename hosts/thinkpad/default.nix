{
  inputs,
  ...
}:

{

  imports = [
    ./configuration.nix
    ./hardware.nix
    ../../modules/nixos/disko/luks.nix
    ./lanzaboote.nix
    ./tlp.nix
    ./awg.nix
    ../../modules/nixos/services/awg-client.nix
    ../../secrets
  ];

  system.stateVersion = "25.11";

}
