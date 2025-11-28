{ lib, ... }:

{
  home = {
    username = "test";
    homeDirectory = "/home/test";
  };

  home.packages = [ ];
  imports =
    lib.map (p: ./. + "/${p}") (
      builtins.filter (p: !(p == "default.nix" || lib.hasSuffix ".txt" p)) (
        lib.attrNames (builtins.readDir ./.)
      )
    )
    ++ [
      ./../../../../modules/home-manager/x86_64-linux/minimal/default.nix
    ];
}
