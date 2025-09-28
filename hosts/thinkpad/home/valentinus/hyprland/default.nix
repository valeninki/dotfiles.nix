{ config, lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    monitor = "1920x1200@60,auto,auto"
  };
}
