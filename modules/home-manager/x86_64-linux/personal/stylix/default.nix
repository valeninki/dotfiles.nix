{ inputs, pkgs, ... }:

{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  stylix = {
    enable = true;
    image = ./../../../../../assets/Wallpapers/prunus.png;
    icons = {
      enable = true;
      package = pkgs.flat-remix-icon-theme;
      light = "Flat-Remix-Red-Light";
      dark = "Flat-Remix-Red-Dark";
    };
    cursor = {
      package = pkgs.catppuccin-cursors.mochaRed;
      name = "catppuccin-mocha-red-cursors";
      size = 24;
    };
    opacity = {
      terminal = 0.7;
    };
    polarity = "dark";
  };
}
