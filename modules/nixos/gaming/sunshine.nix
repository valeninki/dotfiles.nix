{
  config,
  lib,
  pkgs,
  unixpkgs,
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
        package = unixpkgs.sunshine;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
      };
    };
  };
}
