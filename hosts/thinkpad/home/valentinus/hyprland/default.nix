let
  laptop = "eDP-1";
  external = "HDMI-A-1";
in

{
  wayland.windowManager.hyprland.settings = {

    monitor = [
      "${laptop},1920x1200@60,auto,1"
      "${external}, 1920x1080@74.97,auto,1"
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
    ];
  };

  services.hyprpaper.settings = {
    wallpaper = [ "eDP-1,/home/valentinus/Nextcloud/Photos/Wallpapers/Nature/flowers.jpg" ];
  };

}
