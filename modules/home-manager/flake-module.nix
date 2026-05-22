{
  self,
  lib,
  ...
}:

let
  getNixFiles =
    dir:
    let
      files = builtins.readDir dir;
    in
    lib.mapAttrsToList (name: _: dir + "/${name}") (
      lib.filterAttrs (
        name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
      ) files
    );
in
{

  flake = {
    homeModules = {
      cli = {
        imports = getNixFiles ./cli;
      };
      apps = {
        imports = getNixFiles ./apps;
      };
      desktop = {
        imports = getNixFiles ./desktop;
      };

      full-desktop = {
        imports = [
          self.homeModules.cli
          self.homeModules.apps
          self.homeModules.desktop
        ];
      };
    };
  };

}
