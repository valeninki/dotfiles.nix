{ inputs, lib, ... }:

{
  programs.waybar = {
    settings = {
      mainBar = {
        output = [ "eDP-1" ];
      };
    };
  };
}
