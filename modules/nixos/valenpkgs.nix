{
  inputs,
  pkgs,
  ...
}:

{
  _module.args = {
    valenpkgs = inputs.valenpkgs.packages.${pkgs.stdenv.hostPlatform.system};
  };
}
