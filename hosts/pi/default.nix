{
  ...
}:
{
  imports = [
    ./configuration.nix
    ./hardware.nix
    ../../secrets
  ];

  system.stateVersion = "25.11";
}
