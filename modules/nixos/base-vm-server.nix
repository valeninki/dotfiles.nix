{
  lib,
  ...
}:

{
  imports = [
    ./base-server.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };

    kernelParams = [ "ipv6.disable=1" ];
    kernel.sysctl = {
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv6.conf.*.disable_ipv6" = 1;
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };

  networking = {
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };

  powerManagement.cpuFreqGovernor = "performance";

  programs = {
    ssh.startAgent = false;
    wireshark.enable = true;
  };

  services.scx.enable = true;
}
