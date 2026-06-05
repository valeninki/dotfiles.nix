{
  inputs,
  config,
  lib,
  ...
}:

let
  isGarageHost = config.users.users ? garage;
in

{

  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };

    secrets = {
      "garage/rpc_secret" = lib.mkIf isGarageHost {
        owner = "garage";
        group = "garage";
        mode = "0400";
      };
      "garage/admin_token" = lib.mkIf isGarageHost {
        owner = "garage";
        group = "garage";
        mode = "0400";
      };
      "garage/metrics_token" = lib.mkIf isGarageHost {
        owner = "garage";
        group = "garage";
        mode = "0400";
      };
      "amneziawg/desktop_private_key" = {
        mode = "0400";
      };
      "amneziawg/thinkpad_private_key" = {
        mode = "0400";
      };
      "amneziawg/w2_private_key" = {
        mode = "0400";
      };
    };

    templates = lib.mkIf isGarageHost {
      "garage.env" = {
        owner = "garage";
        group = "garage";
        mode = "0400";
        content = ''
          GARAGE_RPC_SECRET=${config.sops.placeholder."garage/rpc_secret"}
          GARAGE_ADMIN_TOKEN=${config.sops.placeholder."garage/admin_token"}
          GARAGE_METRICS_TOKEN=${config.sops.placeholder."garage/metrics_token"}
        '';
      };
    };
  };

}
