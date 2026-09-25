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

  gtk = {
    enable = true;
    iconTheme = {
      name = lib.mkForce "Papirus-Dark";
      package = lib.mkForce (pkgs.papirus-icon-theme.override {
        color = "carmine";
      });
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  stylix.targets.qt.enable = false;
}
