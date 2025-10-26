{
  ...
}:

{
  wayland.windowManager.hyprland.settings = {
    monitor = [ "eDP-1,1920x1200@60,auto,1" ];

    bind = [
      ",XF86MonBrightnessDown, exec, light -U 10"
      ",XF86MonBrightnessUp, exec, light -A 10"
    ];
  };

  services.hyprpaper.settings = {
    wallpaper = [ "eDP-1,/home/valentinus/Nextcloud/Photos/Wallpapers/Nature/flowers.jpg" ];
  };

}
