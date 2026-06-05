{
  inputs,
  ...
}:

{
  imports = [
    ./configuration.nix
    ./hardware.nix
    ./tuned.nix
    ./awg.nix
    ../../secrets
  ];
  system.stateVersion = "25.11";
}
