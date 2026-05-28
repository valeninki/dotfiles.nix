{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.gaming.sunshine;
in
{
  options.profiles.gaming.sunshine = {
    enable = lib.mkEnableOption "Sunshine headless game streaming host";
  };

  config = lib.mkIf cfg.enable {
    services = {
      sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
      };
    };
  };
}
