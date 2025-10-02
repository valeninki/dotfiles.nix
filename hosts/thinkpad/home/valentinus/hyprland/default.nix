{
  config,
  lib,
  pkgs,
  ...
}:

{
  wayland.windowManager.hyprland.settings = {
    monitor = [ "eDP-1,1920x1200@60,auto,1" ];
  };

  services.hyprpaper.settings = {
    wallpaper = [ "eDP-1,/home/valentinus/Nextcloud/Photos/Wallpapers/Nature/flowers.jpg" ];
  };

}
