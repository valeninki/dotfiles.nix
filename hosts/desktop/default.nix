{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.valentinus
    ./host/system/hardware.nix
    ./host/system/configuration.nix
    ./host
    ./home
  ];
  system.stateVersion = "25.11";
}
