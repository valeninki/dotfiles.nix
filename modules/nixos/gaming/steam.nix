{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.gaming.steam;
in
{
  options.profiles.gaming.steam = {
    enable = lib.mkEnableOption "Steam Gaming Environment";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      steam = {
        enable = true;
        package = pkgs.steam.override {
          extraPkgs = pkgs: [ pkgs.libpulseaudio ];
          extraBwrapArgs = [ "--bind /data/Games /data/Games" ];
        };
        dedicatedServer = {
          openFirewall = true;
        };
        remotePlay = {
          openFirewall = true;
        };
      };
    };
  };
}
