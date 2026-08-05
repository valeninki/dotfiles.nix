{ pkgs, ... }:

let
  modifier = "Mod4";
in
{
  home = {
    packages = with pkgs; [
      grim
      pavucontrol
      pcmanfm
      playerctl
      slurp
      tesseract4
      wl-clipboard
      wofi
    ];
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  stylix.targets.sway = {
    enable = true;
    useWallpaper = true;
  };

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway;
    checkConfig = true;
    systemd.enable = true;
    xwayland = true;

    config = {
      inherit modifier;
      terminal = "kitty";
      menu = "wofi --show drun";
      bindkeysToCode = true;
      bars = [ ];

      input."*".xkb_layout = "tr";
      input."type:touchpad".tap = "enabled";

      gaps = {
        inner = 5;
        outer = 5;
      };

      window = {
        border = 2;
        titlebar = false;
        commands = [
          {
            criteria.title = "Picture-in-Picture";
            command = "sticky enable";
          }
        ];
      };

      floating = {
        border = 2;
        titlebar = false;
        inherit modifier;
        criteria = [
          { app_id = "org.pulseaudio.pavucontrol"; }
          { class = "Pavucontrol"; }
          { title = "Picture-in-Picture"; }
        ];
      };

      keybindings = {
        "${modifier}+t" = "exec kitty";
        "${modifier}+d" = "exec wofi --show drun";
        "${modifier}+e" = "exec pcmanfm";
        "${modifier}+z" = "exec zeditor";
        "${modifier}+q" = "kill";
        "${modifier}+c" = "exec cliphist list | wofi --dmenu | cliphist decode | wl-copy";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+l" = "exec swaylock";

        "${modifier}+Left" = "focus left";
        "${modifier}+Right" = "focus right";
        "${modifier}+Up" = "focus up";
        "${modifier}+Down" = "focus down";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";

        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";

        "${modifier}+button4" = "workspace prev";
        "${modifier}+button5" = "workspace next";

        "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPause" = "exec playerctl play-pause";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioPrev" = "exec playerctl previous";

        "${modifier}+Shift+s" = "exec grim -g \"$(slurp -d)\" - | wl-copy";
        "${modifier}+Shift+a" = "exec grim -g \"$(slurp)\" - | tesseract stdin stdout -l tur | wl-copy";
      };
    };
  };
}
