{
  inputs,
  ...
}:

{
  imports = [
    ./configuration.nix
	./hardware.nix
	./tuned.nix
	./awg.nix
  ];
  system.stateVersion = "25.11";
}
