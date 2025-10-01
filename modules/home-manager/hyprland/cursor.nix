{ pkgs, inputs, config, ... }:

{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    cursors = {
      enable = true;
      accent = "yellow";
      flavor = "frappe";
    };
  };
}
