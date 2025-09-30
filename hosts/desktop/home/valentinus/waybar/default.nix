{ inputs, lib, ... }:

{
  programs.waybar = {
    settings = {
      mainBar = {
        output = [
          "HDMI-A-1"
        ];
      };
    };
  };
}
