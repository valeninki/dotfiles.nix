{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.test
    ./host/system/configuration.nix
    ./host/system/hardware-configuration.nix
  ];
  system.stateVersion = "25.05";
}
