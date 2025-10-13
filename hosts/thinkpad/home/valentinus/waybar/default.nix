{
  programs.waybar = {
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
      };
    };
  };
}
