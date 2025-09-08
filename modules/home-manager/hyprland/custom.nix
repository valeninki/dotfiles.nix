{ pkgs, ...}:

{
gtk = {
  enable = true;
  theme.package = pkgs.gruvbox-dark-gtk;
  theme.name = "gruvbox-dark";
};

qt = {
  enable = true;
  platformTheme.name = "gtk";
  style.name = "Gruvbox-Dark-Brown";
  style.package= pkgs.gruvbox-kvantum;
};

}
