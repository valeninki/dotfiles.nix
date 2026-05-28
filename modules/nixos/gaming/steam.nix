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
