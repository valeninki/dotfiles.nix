{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.s3;
in

{

  imports = [
    ../../../secrets
  ];

  options.services.s3.enable = lib.mkEnableOption "Garage S3 Object Storage Node";

  config = lib.mkIf cfg.enable {

    sops = {
      secrets = {
        "garage/rpc_secret" = {
          owner = "root";
          group = "root";
          mode = "0400";
        };
        "garage/admin_token" = {
          owner = "root";
          group = "root";
          mode = "0400";
        };
        "garage/metrics_token" = {
          owner = "root";
          group = "root";
          mode = "0400";
        };
      };

      templates = {
        "garage.env" = {
          # systemd reads this before dropping privileges to Garage's DynamicUser.
          owner = "root";
          group = "root";
          mode = "0400";
          content = ''
            GARAGE_RPC_SECRET=${config.sops.placeholder."garage/rpc_secret"}
            GARAGE_ADMIN_TOKEN=${config.sops.placeholder."garage/admin_token"}
            GARAGE_METRICS_TOKEN=${config.sops.placeholder."garage/metrics_token"}
          '';
        };
        "garage-webui.env" = {
          # The Web UI uses a different environment variable name for the same token.
          owner = "root";
          group = "root";
          mode = "0400";
          content = ''
            API_ADMIN_KEY=${config.sops.placeholder."garage/admin_token"}
          '';
        };
      };
    };

    networking = {
      firewall = {
        allowedTCPPorts = [
          3900
          3901
          3902
          3903
          3904
          3909
        ];
      };
    };

    services = {
      garage = {
        enable = true;
        package = pkgs.garage_2;
        settings = {

          metadata_dir = "/var/lib/garage/meta";
          data_dir = "/var/lib/garage/data";
          db_engine = "sqlite";

          replication_factor = 1;

          rpc_bind_addr = "[::]:3901";
          rpc_public_addr = "127.0.0.1:3901";
          rpc_secret = ""; # placeholder, overridden by environment file

          s3_api = {
            s3_region = "garage";
            api_bind_addr = "[::]:3900";
            root_domain = ".s3.garage.localhost";
          };

          s3_web = {
            bind_addr = "[::]:3902";
            root_domain = ".web.garage.localhost";
            index = "index.html";
          };

          k2v_api = {
            api_bind_addr = "[::]:3904";
          };

          admin = {
            api_bind_addr = "[::]:3903";
            admin_token = ""; # placeholder, overridden by environment file
            metrics_token = ""; # placeholder, overridden by environment file
          };
        };
        environmentFile = config.sops.templates."garage.env".path;
      };
    };

    systemd = {
      services = {
        garage-webui = {
          description = "Garage Web UI";
          after = [
            "network.target"
            "garage.service"
          ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            DynamicUser = true;
            Environment = [
              "PORT=3909"
              "API_BASE_URL=http://127.0.0.1:3903"
              "S3_ENDPOINT_URL=http://127.0.0.1:3900"
              "S3_REGION=garage"
            ];
            EnvironmentFile = config.sops.templates."garage-webui.env".path;
            ExecStart = "${pkgs.garage-webui}/bin/garage-webui";
            Restart = "always";
          };
        };
      };
    };
  };

}
