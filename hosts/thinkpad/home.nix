{ pkgs, ... }:

let
  laptop = "eDP-1";
  external = "HDMI-A-1";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  micmute = pkgs.writeShellScript "thinkpad-micmute" ''
    if [ "$1" = toggle ]; then
      ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle || exit
    fi
    state=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@) || exit
    case "$state" in
      *'[MUTED]'*) echo 1 > /sys/class/leds/platform::micmute/brightness ;;
      *) echo 0 > /sys/class/leds/platform::micmute/brightness ;;
    esac
  '';
in

{

  home.packages = [ pkgs.brightnessctl ];

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
        render_bit_depth = "8";
        position = "0 0";
        scale = "1";
      };
      "${external}" = {
        mode = "1920x1080@74.97Hz";
        position = "1920 0";
        scale = "1";
      };
    };

    startup = [
      { command = "${brightnessctl} -d amdgpu_bl1 set 28%"; }
      { command = "${micmute} sync"; }
    ];

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
      "XF86MonBrightnessDown" = "exec ${brightnessctl} -d amdgpu_bl1 set 5%-";
      "XF86MonBrightnessUp" = "exec ${brightnessctl} -d amdgpu_bl1 set +5%";
      "XF86AudioMicMute" = "exec ${micmute} toggle";
    };
  };

}
