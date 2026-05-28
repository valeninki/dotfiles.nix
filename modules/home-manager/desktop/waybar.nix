{

  programs = {
    waybar = {
      enable = true;
      settings = {
        mainBar = {
          position = "top";
          height = 30;
          modules-left = [
            "custom/space"
            "hyprland/workspaces"
          ];
          modules-center = [ "hyprland/window" ];
          modules-right = [
            "custom/space"
            "network"
            "custom/space"
            "memory"
            "custom/space"
            "pulseaudio"
            "custom/space"
            "clock"
            "custom/space"
            "battery"
            "custom/space"
            "backlight"
            "custom/space"
            "tray"
            "custom/space"
            "custom/power"
            "custom/space"
          ];

          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              active = "";
              default = "";
            };
          };

          "network" = {
            interface = [
              "enp2s0"
              "enp3s0"
              "tailscale0"
              "awg0"
            ];
            format-wifi = "󰖩 ";
            format-ethernet = " ";
            format-disconnected = " ";
            tooltip-format = "{essid} {ipaddr}/{cidr}";
          };

          "clock" = {
            format = "  {:%H:%M}";
            format-alt = "{:%A, %B %d, %Y (%R)} 󰸘 ";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              format = {
                months = "<span color='#f06161'><b>{}</b></span>";
                days = "<span color='#e8e1df'><b>{}</b></span>";
                weeks = "<span color='#75676b'><b>W{}</b></span>";
                weekdays = "<span color='#ac8791'><b>{}</b></span>";
                today = "<span color='#e8e1df' bgcolor='#484649'><b><u>{}</u></b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-scroll-up = [
                "tz_up"
                "shift_up"
              ];
              on-scroll-down = [
                "tz_down"
                "shift_down"
              ];

            };
          };

          "memory" = {
            interval = 30;
            format = "  {used:0.1f}G/{total:0.1f}G";
          };

          "pulseaudio" = {
            format = "{icon} {volume}%";
            format-muted = " ";
            format-source = " {volume}% ";
            format-source-muted = "󰍭 ";
            scroll-step = 1;
            on-click = "pavucontrol";
            format-icons = {
              headphone = "󰋋 ";
              headset = " ";
              default = [
                " "
                " "
                " "
              ];
            };
          };

          "tray" = {
            icon-size = 21;
            spacing = 10;
          };

          "custom/space" = {
            format = "  ";
            tooltip = false;
          };

          "custom/power" = {
            format = "⏻ ";
            on-click = "poweroff";
          };
        };
      };
    };
  };

}
