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
  ];

  system.stateVersion = "25.11";

}
