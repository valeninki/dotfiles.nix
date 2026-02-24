{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
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
    iperf3
  ];
  services = {
    fprintd = {
      enable = true;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-goodix-550a;
      };
    };
    fwupd = {
      enable = true;
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
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = "*";
        };
      };
    };
  };
}
