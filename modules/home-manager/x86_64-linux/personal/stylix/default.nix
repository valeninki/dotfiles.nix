{ inputs, pkgs, ... }:

{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  stylix = {
    enable = true;
    image = ./../../../../../assets/Wallpapers/yellow_rose-1920x1200.png;
    icons = {
      enable = true;
      package = pkgs.flat-remix-icon-theme;
      light = "Flat-Remix-Yellow-Light";
      dark = "Flat-Remix-Yellow-Dark";
    };
    cursor = {
      package = pkgs.catppuccin-cursors.mochaYellow;
      name = "catppuccin-mocha-yellow-cursors";
      size = 24;
    };
    opacity = {
      terminal = 0.7;
    };
    polarity = "dark";
  };
}
