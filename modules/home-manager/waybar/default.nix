{
  programs.waybar = {
  enable = true;
  settings = {
    mainBar = {
    position = "top";
    height = 30;
    output = [
      "HDMI-A-1"
    ];
    modules-left = [ "custom/space" "hyprland/workspaces" ];
    modules-center = [ "hyprland/window" ];
    modules-right = [ "mpd" "network" "clock" "memory" "pulseaudio" "tray"];

    "hyprland/workspaces" = {
      format = "{icon}";
      format-icons = {
              active = "";
              default = "";
      };
    };

    "network" = {
      interface = [
      "enp34s0"
      "tun0"
      ];
      format-ethernet = "{ipaddr}/{cidr}";
      format-disconnected = " ";
      tooltip-format = "{ifname} via {gwaddr}";
      tooltip-format-ethernet = "{ifname}";
      tooltip-format-disconnected = "Disconnected";
    };

    "clock" = {
        format = "{:%H:%M}  ";
        format-alt = "{:%A, %B %d, %Y (%R)}  ";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
                    mode = "year";
                    mode-mon-col = 3;
                    weeks-pos = "right";
                    on-scroll = 1;
                    format = {
                              months = "<span color='#6F3518'><b>{}</b></span>";
                              days = "<span color='#7E5030'><b>{}</b></span>";
                              weeks = "<span color='#f8e9e9'><b>W{}</b></span>";
                              weekdays = "<span color='#524837'><b>{}</b></span>";
                              today = "<span color='#67131E'><b><u>{}</u></b></span>";
                              };
                    };
        actions =  {
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
      format = "{used:0.1f}G/{total:0.1f}G";

    };

    "pulseaudio" = {
      format = "{volume}% {icon}";
      format-muted = "Muted";
      scroll-step = 1;
      on-click = "pavucontrol";
    };

    "tray" = {
      icon-size = 21;
      spacing = 10;
    };
 };
  };

  style = ''
    window#waybar {
      background-color: rgba(38, 47, 40, 0.8);
      color: rgba(126, 80, 48, 1.0);
      border-radius: 50px;
      margin: 10px;
    }
   #workspaces button {
      color: rgba(126, 80, 48, 1.0);
   }
   #workspaces button.active {
      color: rgba(103, 19, 30, 1.0);
   }
   #network, #clock, #memory, #pulseaudio, #tray {
      padding: 0 10px;
      margin: 10px;
      border-radius: 50px;
/*      background-color: rgba(0, 49, 44, 0.6); */
   }
  '';
 };
}
