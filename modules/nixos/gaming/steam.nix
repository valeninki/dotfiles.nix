{
  config,
  lib,
  unixpkgs,
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
        package = unixpkgs.steam.override {
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
