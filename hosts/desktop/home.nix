{
  config,
  pkgs,
  ...
}:

{

  wayland = {
    windowManager = {
      hyprland = {
        settings = {
          monitor = [
            "HDMI-A-1, 1920x1080@74.97,auto,1"
          ];
        };
      };
    };
  };

  programs = {
    waybar = {
      settings = {
        mainBar = {
          output = [ "HDMI-A-1" ];
        };
      };
    };
  };

}
