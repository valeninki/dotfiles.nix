{
  inputs,
  pkgs,
  ...
}:

{
  _module.args = {
    valenpkgs = inputs.valenpkgs.packages.${pkgs.stdenv.hostPlatform.system} // {
      devilutionx = pkgs.callPackage (inputs.valenpkgs + "/modules/nixos/devilutionx") { };
    };
  };
}
