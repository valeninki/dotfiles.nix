{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.valentinus
    ./host/hardware-configuration.nix
    ./host/configuration.nix
    ./host
    ./home
  ];
  system.stateVersion = "25.05";
}
