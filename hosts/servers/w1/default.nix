{
  inputs,
  ...
}:

{
  imports = [
    inputs.self.nixosModules.valen
    ./host/system
    ./host/system/hardware.nix
    ./host
    ./home
  ];
  system.stateVersion = "25.11";
}
