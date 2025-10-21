{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.berry
    ./host/system/configuration.nix
    ./host/system/hardware.nix
    ./host
    ./home
  ];
  system.stateVersion = "25.05";
}
