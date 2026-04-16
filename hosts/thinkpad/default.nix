{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.valentinus
    ./host/system/configuration.nix
    ./host/system/hardware.nix
    ./../disko/luks.nix
    ./host
    ./home
  ];
  system.stateVersion = "25.11";
}
