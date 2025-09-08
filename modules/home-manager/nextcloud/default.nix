{ pkgs ,config, lib, ... }:

{
    services.nextcloud-client = {
      enable = true;
      package =pkgs.nextcloud-client;
      startInBackground = true;
    };
}
