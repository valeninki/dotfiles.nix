{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.valentinus
    ./host/configuration.nix
    ./host/hardware-configuration.nix
    ./host
    ./home
  ];
  system.stateVersion = "25.05";
}
