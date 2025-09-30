{ inputs, ... }:

{
  imports = [
    ./luks.nix
  ];
  system.stateVersion = "25.05";
}
