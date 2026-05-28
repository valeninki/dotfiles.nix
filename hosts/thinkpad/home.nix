{
  config,
  pkgs,
  ...
}:

let
  laptop = "eDP-1";
  external = "HDMI-A-1";
in

{

  wayland = {
    windowManager = {
      hyprland = {
        settings = {

          monitor = [
            "${laptop},1920x1200@60,auto,1"
            "${external},1920x1080@74.97,auto,1"
          ];

          workspace = [
            "1, monitor:${laptop}"
            "2, monitor:${laptop}"
            "3, monitor:${laptop}"
            "4, monitor:${laptop}"
            "5, monitor:${laptop}"
            "6, monitor:${external}"
            "7, monitor:${external}"
            "8, monitor:${external}"
            "9, monitor:${external}"
          ];

          bind = [
            ",XF86MonBrightnessDown, exec, light -U 10"
            ",XF86MonBrightnessUp, exec, light -A 10"
            ",XF86AudioMicMute, exec, amixer -c 1 sset Capture toggle"
            ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ];

        };
      };
    };
  };

  programs = {
    waybar = {
      settings = {
        mainBar = {
          output = [ "eDP-1" ];

          "battery" = {
            bat = "BAT0";
            interval = 60;
            states = {
              warning = 45;
              critical = 20;
            };
            format = "{icon} {capacity}%";
            format-icons = [
              "󰁺"
              "󰁻"
              "󰁾"
              "󰂀"
              "󰁹"
            ];
          };
          "backlight" = {
            "device" = "amdgpu_bl1";
            "format" = "{icon} {percent}%";
            "format-icons" = [
              "󰃠 "
              "󰃟 "
              "󰃝 "
              "󰃞 "
            ];
          };
        };
      };
    };
  };

}
