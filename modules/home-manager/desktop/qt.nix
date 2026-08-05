{ lib, pkgs, ... }:

{
  home = {
    packages = [
      pkgs.qt6Packages.qt6ct
      pkgs.adwaita-qt
    ];

    sessionVariables = {
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_STYLE_OVERRIDE = lib.mkForce "Adwaita-dark";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  stylix.targets.qt.enable = false;
}
