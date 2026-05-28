{
  lib,
  ...
}:

let
  files = builtins.readDir ./.;

  nixFiles = lib.filterAttrs (
    name: type: type == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name
  ) files;
in
{
  imports = map (name: ./. + "/${name}") (builtins.attrNames nixFiles);
}
