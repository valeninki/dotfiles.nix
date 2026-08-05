_:

let
  laptop = "eDP-1";
  external = "HDMI-A-1";
in

{

  valentinus.desktop.quickshell = {
    enable = true;
    capabilities = {
      iwd.enable = true;
      backlight.enable = true;
      battery = {
        enable = true;
        device = "BAT0";
      };
    };
  };

  wayland.windowManager.sway.config = {
    output = {
      "${laptop}" = {
        mode = "1920x1200@60Hz";
        position = "0 0";
        scale = "1";
      };
      "${external}" = {
        mode = "1920x1080@74.97Hz";
        position = "1920 0";
        scale = "1";
      };
    };

    workspaceOutputAssign = [
      {
        workspace = "1";
        output = laptop;
      }
      {
        workspace = "2";
        output = laptop;
      }
      {
        workspace = "3";
        output = laptop;
      }
      {
        workspace = "4";
        output = laptop;
      }
      {
        workspace = "5";
        output = laptop;
      }
      {
        workspace = "6";
        output = external;
      }
      {
        workspace = "7";
        output = external;
      }
      {
        workspace = "8";
        output = external;
      }
      {
        workspace = "9";
        output = external;
      }
    ];

    keybindings = {
      "XF86MonBrightnessDown" = "exec brightnessctl set 10%-";
      "XF86MonBrightnessUp" = "exec brightnessctl set +10%";
      "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    };
  };

}
