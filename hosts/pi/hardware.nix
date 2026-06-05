{
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "usbhid"
        "ext4"
        "pcie-brcmstb"
        "reset-raspberrypi"
        "genet"
        "sdhci_iproc"
        "mmc_block"
      ];
      kernelModules = [ ];
    };
    kernelParams = [
      "quiet"
      "loglevel=3"
      "rd.systemd.show_status=0"
      "rd.udev.log_level=3"
      "cma=256M"
    ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXOS_BOOT";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
      "discard"
      "errors=remount-ro"
    ];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8192;
    }
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  networking = {
    useDHCP = lib.mkDefault true;
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "aarch64-linux";
  };

}
