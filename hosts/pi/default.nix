{
  ...
}:

{

  imports = [
    ./configuration.nix
    ./hardware.nix
    ./tailscale.nix
  ];

  system.stateVersion = "25.11";

}
