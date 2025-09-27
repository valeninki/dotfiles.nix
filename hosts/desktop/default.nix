{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
    inputs.self.nixosModules.valentinus
    ./host
    ./home
  ];
  system.stateVersion = "25.05";
}
