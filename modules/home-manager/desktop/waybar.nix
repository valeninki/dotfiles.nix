{ config, lib, ... }:

let
  c = config.lib.stylix.colors;
  font = config.stylix.fonts.monospace.name;
in

{
  stylix.targets.waybar.enable = false;

  programs.waybar = {
    enable = true;
    style = ''
      @define-color base00 #${c.base00};
      @define-color base01 #${c.base01};
      @define-color base02 #${c.base02};
      @define-color base03 #${c.base03};
      @define-color base04 #${c.base04};
      @define-color base05 #${c.base05};
      @define-color base06 #${c.base06};
      @define-color base07 #${c.base07};
      @define-color base08 #${c.base08};
      @define-color base09 #${c.base09};
      @define-color base0A #${c.base0A};
      @define-color base0B #${c.base0B};
      @define-color base0C #${c.base0C};
      @define-color base0D #${c.base0D};
      @define-color base0E #${c.base0E};
      @define-color base0F #${c.base0F};

      * {
        font-family: "${font}";
        font-size: 10pt;
      }

      window#waybar {
        background: transparent;
        color: @base05;
      }

      window#waybar > box {
        margin: 0;
      }

      .modules-left, .modules-center, .modules-right {
        background: alpha(@base00, 0.85);
        border-radius: 16px;
        margin: 8px 4px 0;
        padding: 0 4px;
      }

      tooltip {
        background: alpha(@base00, 0.9);
        color: @base05;
        border: 1px solid @base02;
        border-radius: 8px;
      }

      #workspaces button {
        padding: 2px 8px;
        border-radius: 8px;
        color: @base05;
        font-weight: bold;
      }

      #workspaces button.active {
        background: @base08;
        color: @base00;
      }

      #workspaces button.urgent {
        background: @base0A;
        color: @base00;
      }

      #network, #memory, #pulseaudio, #clock, #tray,
      #battery, #backlight, #custom-power {
        padding: 2px 10px;
        margin: 4px 2px;
        border-radius: 12px;
        background: @base01;
      }

      #window {
        padding: 0 12px;
      }

      #clock {
        background: @base02;
        font-weight: bold;
      }

      #battery.warning {
        background: @base0A;
        color: @base00;
      }

      #battery.critical {
        background: @base08;
        color: @base00;
        animation: blink 1s infinite;
      }

      @keyframes blink {
        to {
          background: @base01;
        }
      }

      #pulseaudio.muted {
        color: @base03;
      }

      #idle_inhibitor {
        padding: 2px 10px;
        margin: 4px 2px;
        border-radius: 12px;
        background: @base01;
      }

      #idle_inhibitor.activated {
        background: @base08;
        color: @base00;
      }

      #tray {
        background: transparent;
      }
    '';

    settings = {
      mainBar = {
        position = "top";
        height = 30;
        modules-left = lib.mkDefault [ "hyprland/workspaces" ];
        modules-center = lib.mkDefault [ "hyprland/window" ];
        modules-right = lib.mkDefault [
          "network"
          "memory"
          "pulseaudio"
          "clock"
          "battery"
          "backlight"
          "tray"
          "custom/power"
        ];

        "hyprland/workspaces" = {
          format = "{id}";
        };

        "network" = {
          interface = lib.mkDefault [
            "enp2s0"
            "enp3s0"
            "tailscale0"
            "awg0"
          ];
          format-wifi = "󰖩 {essid}";
          format-ethernet = "󰈀 {ipaddr}";
          format-disconnected = "󰀦 ";
          tooltip-format = "{essid} {ipaddr}/{cidr}";
        };

        "clock" = {
          format = " {:%H:%M}";
          format-alt = "󰸘 {:%A, %B %d, %Y (%R)}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#${c.base0E}'><b>{}</b></span>";
              days = "<span color='#${c.base05}'><b>{}</b></span>";
              weeks = "<span color='#${c.base03}'><b>W{}</b></span>";
              weekdays = "<span color='#${c.base0D}'><b>{}</b></span>";
              today = "<span color='#${c.base00}' bgcolor='#${c.base08}'><b><u>{}</u></b></span>";
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
          format = " {used:0.1f}G/{total:0.1f}G";
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

        "custom/power" = {
          format = "⏻ ";
          on-click = "poweroff";
        };
      };
    };
  };
}
