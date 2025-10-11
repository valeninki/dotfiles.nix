{ inputs, pkgs, ... }:

{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  stylix = {
    enable = true;
    image = /home/valentinus/Nextcloud/Photos/Wallpapers/Nature/flowers.jpg;
    icons = {
      enable = true;
      package = pkgs.flat-remix-icon-theme;
      light = "Flat-Remix-Orange-Light";
      dark = "Flat-Remix-Orange-Dark";
    };
    cursor = {
      package = pkgs.catppuccin-cursors.mochaPeach;
      name = "catppuccin-mocha-peach-cursors";
      size = 24;
    };
    opacity = {
      terminal = 0.7;
    };
    polarity = "dark";
  };
}
