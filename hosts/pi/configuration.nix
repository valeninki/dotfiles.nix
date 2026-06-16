{
  pkgs,
  lib,
  inputs,
  unixpkgs,
  ...
}:

{
  networking = {
    hostName = "pi";
    useNetworkd = true;
  };

  systemd.network = {
    enable = true;
    networks."10-end0" = {
      matchConfig.Name = "end0";
      networkConfig = {
        DHCP = "yes";
      };
      linkConfig = {
        RequiredForOnline = "routable";
      };
    };
  };

  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    packages = [ pkgs.terminus_font ];
    font = "ter-v16b";
    keyMap = lib.mkForce "trq";
    useXkbConfig = true;
    earlySetup = true;
  };

  users = {
    users = {
      berry = {
        isNormalUser = true;
        home = "/home/berry";
        shell = pkgs.fish;
        initialPassword = "berry";
        extraGroups = [ "wheel" ];
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

  programs = {
    nix-ld.enable = true;
    fish.enable = true;
  };

  services.s3.enable = true;

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

}
