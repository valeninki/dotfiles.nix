{
  lib,
  ...
}:

{
  programs = {
    kitty = {
      enable = true;

      font = lib.mkForce {
        name = "FiraCode Nerd Font";
        size = 12.0;
      };

      settings = {
        linux_display_server = "wayland";
        wayland_titlebar_color = "background";
      };
    };
  };
}
