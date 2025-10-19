{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.valentinus
    ./host/configuration.nix
    ./host/hardware-configuration.nix
    ./../disko/luks.nix
    ./host
    ./home
  ];
  system.stateVersion = "25.05";
}
