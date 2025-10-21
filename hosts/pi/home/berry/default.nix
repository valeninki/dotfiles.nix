{ inputs, lib, ... }:

{
  home = {
    username = "berry";
    homeDirectory = "/home/berry";
  };

  home.packages = [ ];
  imports =
    lib.map (p: ./. + "/${p}") (
      builtins.filter (p: !(p == "default.nix" || lib.hasSuffix ".txt" p)) (
        lib.attrNames (builtins.readDir ./.)
      )
    )
    ++ [
      inputs.self.homeManagerModules.berry
    ];
}
