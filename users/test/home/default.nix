{
  lib,
  config,
  pkgs,
  unixpkgs,
  inputs,
  ...
}:

{
  home = {
    stateVersion = "25.05";
  };

  home.packages = with pkgs; [
    
    ## Must have packages
    sl
    tmate
    openssl
    git

    ## Monitoring Packages
    fastfetch
    htop
    btop
    inxi
    gping
    gdu
  ];

  home.activation = { };
  imports =
    lib.map (p: ./. + "/${p}") (lib.remove "default.nix" (lib.attrNames (builtins.readDir ./.)))
    ++ [ inputs.self.homeManagerModules.test ];
}
