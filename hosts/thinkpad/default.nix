{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.valentinus
    ./host
    ./home
  ];
  system.stateVersion = "25.05";
}
