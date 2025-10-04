{ inputs, lib, ... }:

{
  programs.waybar = {
    settings = {
      mainBar = {
        output = [ "eDP-1" ];
      };

      "battery" = {
        bat = "L22B3PG5";
        interval = 60;
        states = {
          warning = 45;
          critical = 20;
        };
        format = "{capacity}% {icon}";
        format-icons = [ ];
        max-length = 25;
      };
    };

    style = ''
         #battery {
            padding: 0 10px;
            margin: 10px;
            border-radius: 50px;
      /*      background-color: rgba(0, 49, 44, 0.6); */
         }
    '';
  };
}
