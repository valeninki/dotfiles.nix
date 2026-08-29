{
  pkgs,
  ...
}:

{
  imports = [
    ./base.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      iperf3
    ];
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
      };
    };
    tailscale = {
      useRoutingFeatures = "server";
    };
  };
}
