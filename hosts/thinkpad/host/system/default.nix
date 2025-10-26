{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wget
    networkmanagerapplet
    gparted
    e2fsprogs
    duperemove
    dmidecode
    libva-utils
    lm_sensors
    v4l-utils
    xdg-user-dirs
    xdg-utils
    wakeonlan
  ];
  services = {
    fprintd = {
      enable = true;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-goodix-550a;
      };
    };
  };
  systemd.services = {
    fprintd = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "simple";
    };
  };
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
