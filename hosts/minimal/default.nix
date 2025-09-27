{ inputs, ... }:

{
  imports = [
  ];
  moduleopts.nixos = {
    lanzaboote.enable = true;
  };
  system.stateVersion = "25.05";
}
