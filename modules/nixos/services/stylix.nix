{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;
    image = lib.mkDefault ../../../assets/Wallpapers/prunus.png;
    fonts = {
      sansSerif = {
        package = pkgs.fira;
        name = "Fira Sans";
      };

      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };

      monospace = {
        name = "FiraCode Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
    icons = {
      enable = true;
      package = lib.mkDefault pkgs.flat-remix-icon-theme;
      light = lib.mkDefault "Flat-Remix-Red-Light";
      dark = lib.mkDefault "Flat-Remix-Red-Dark";
    };
    cursor = {
      package = lib.mkDefault pkgs.catppuccin-cursors.mochaRed;
      name = lib.mkDefault "catppuccin-mocha-red-cursors";
      size = lib.mkDefault 24;
    };
    opacity = {
      terminal = 0.7;
    };
    polarity = "dark";

    targets = {
      chromium.enable = false;
    };
  };
}
