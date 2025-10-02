{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; 
       [
        wget
        networkmanagerapplet
        gparted
        e2fsprogs
        duperemove
	dmidecode
	libva-utils
	lm_sensors
	v4l-utils
       ];

  xdg = {
    autostart.enable = true;
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
      ];
      config.common.default = "*";
    };
  };
}
