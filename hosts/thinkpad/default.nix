{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.thinkpad
    ./host
    ./home
  ];
  system.stateVersion = "25.05";
}
