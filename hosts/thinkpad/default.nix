{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosModules.thinkpad
    ./host
    ./home
  ];
  system.stateVersion = "25.05";
}
