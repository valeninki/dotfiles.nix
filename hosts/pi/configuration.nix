{
  pkgs,
  config,
  ...
}:

{
  networking = {
    hostName = "pi";
    useNetworkd = true;
    useDHCP = false;
  };

  systemd.network = {
    enable = true;
    networks."10-ethernet" = {
      matchConfig.Type = "ether";
      networkConfig = {
        DHCP = "yes";
      };
      linkConfig = {
        RequiredForOnline = "routable";
      };
    };
  };

  console.useXkbConfig = true;

  sops.secrets = {
    "pi/root_password" = {
      sopsFile = ../../secrets/host-secrets.yaml;
      neededForUsers = true;
    };
    "pi/berry_password" = {
      sopsFile = ../../secrets/host-secrets.yaml;
      neededForUsers = true;
    };
  };

  users = {
    mutableUsers = false;

    users = {
      root.hashedPasswordFile = config.sops.secrets."pi/root_password".path;

      berry = {
        isNormalUser = true;
        home = "/home/berry";
        shell = pkgs.fish;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.sops.secrets."pi/berry_password".path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJKD4C1Wkdb5T4Q3USTohWdywj8mKGiWy+HOg/934ip valentinus@thinkpad"
        ];
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      git
      wget
      ethtool
      doas-sudo-shim
    ];
  };

  services.s3.enable = true;

  nix.settings.auto-optimise-store = true;

}