{ pkgs, inputs, ... }:

let
  valenpkgs = inputs.valenpkgs.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    inputs.valenpkgs.nixosModules.valenpkgs
  ];

  environment.systemPackages = with valenpkgs; [
    zmem
    topmem
  ];
}
