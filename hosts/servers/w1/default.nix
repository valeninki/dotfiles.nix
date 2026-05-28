{
  inputs,
  ...
}:

{
  imports = [
    ./configuration.nix
    ./hardware.nix
    ./tuned.nix
  ];
  system.stateVersion = "25.11";
}
