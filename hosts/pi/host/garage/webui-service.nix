{
  pkgs,
  ...
}:

{
  systemd.services.garage-webui = {
    description = "Garage Web UI";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "root";
      Environment = "PORT=3909";
      ExecStart = "${pkgs.garage-webui}/bin/garage-webui";
      Restart = "always";
    };
  };
}
