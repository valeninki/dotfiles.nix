{ inputs, pkgs, ... }:

{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  stylix = {
    enable = true;
    image = ./../../../../../assets/Wallpapers/purple_flowers.png;
    icons = {
      enable = true;
      package = pkgs.flat-remix-icon-theme;
      light = "Flat-Remix-Magenta-Light";
      dark = "Flat-Remix-Magenta-Dark";
    };
    cursor = {
      package = pkgs.catppuccin-cursors.mochaLavender;
      name = "catppuccin-mocha-lavender-cursors";
      size = 24;
    };
    opacity = {
      terminal = 0.7;
    };
    polarity = "dark";
  };
}
