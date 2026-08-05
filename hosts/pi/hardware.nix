{ lib, pkgs, ... }:

{
  boot = {
    loader = {
      timeout = 1;
      generic-extlinux-compatible = {
        enable = true;
        useGenerationDeviceTree = true;
      };
      grub.enable = false;
    };

    kernelPackages = lib.mkForce pkgs.linuxPackages;

    initrd.availableKernelModules = [
      "pcie-brcmstb"
      "reset-raspberrypi"
      "bcm2835_wdt"
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];

    kernelParams = [
      "zswap.enabled=0"
      "cpuidle.off=1"
      "processor.max_cstate=1"
    ];

    kernel.sysctl = {
      "vm.dirty_ratio" = 20;
      "vm.dirty_background_ratio" = 10;
      "vm.dirty_writeback_centisecs" = 1000;
      "vm.swappiness" = 30;
      "vm.vfs_cache_pressure" = 50;
      "vm.overcommit_memory" = 1;
      "vm.min_free_kbytes" = 32768;
      "net.core.somaxconn" = 1024;
      "net.core.netdev_max_backlog" = 1024;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;
      "net.core.rmem_default" = 262144;
      "net.core.wmem_default" = 262144;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 15;
      "net.ipv4.tcp_keepalive_time" = 300;
      "net.ipv4.tcp_keepalive_intvl" = 30;
      "net.ipv4.tcp_keepalive_probes" = 5;
      "net.ipv4.tcp_max_syn_backlog" = 1024;
      "net.ipv4.tcp_rmem" = "4096 87380 16777216";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      "net.ipv4.ip_local_port_range" = "1024 65535";
    };
  };

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "10%";
  };

  fileSystems."/boot/firmware".neededForBoot = true;

  nixpkgs = {
    hostPlatform = lib.mkDefault "aarch64-linux";
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "ondemand";
  };

  zramSwap = {
    enable = lib.mkDefault true;
    algorithm = "zstd";
    memoryPercent = lib.mkDefault 25;
    priority = 100;
  };

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.powerOnBoot = lib.mkDefault false;
    deviceTree.filter = lib.mkDefault "bcm2711-rpi-*.dtb";
    raspberry-pi = {
      "4".apply-overlays-dtmerge.enable = false;
      firmware.enable = false;
    };
  };

  services = {
    fstrim.enable = true;
    irqbalance.enable = true;
    journald.extraConfig = ''
      SystemMaxUse=50M
      SystemMaxFileSize=10M
      MaxRetentionSec=7day
      Compress=yes
    '';
  };

  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
  };

  system.activationScripts.rpi-boot-firmware =
    let
      configTxt = ./config.txt;
      rpiFw = "${pkgs.raspberrypifw}/share/raspberrypi/boot";
    in
    {
      text = ''
        FIRMWARE="/boot/firmware"
        if mountpoint -q "$FIRMWARE"; then
          CURRENT_HASH=$(cat "$FIRMWARE/.nix-firmware-hash" 2>/dev/null || echo "")
          NEW_HASH=$(echo "${pkgs.raspberrypifw} ${pkgs.ubootRaspberryPi4_64bit} ${pkgs.raspberrypi-armstubs} ${configTxt}" | sha256sum | cut -d' ' -f1)

          if [ "$CURRENT_HASH" != "$NEW_HASH" ]; then
            cp ${rpiFw}/bootcode.bin "$FIRMWARE/"
            cp ${rpiFw}/fixup4.dat "$FIRMWARE/"
            cp ${rpiFw}/fixup4db.dat "$FIRMWARE/"
            cp ${rpiFw}/fixup4x.dat "$FIRMWARE/"
            cp ${rpiFw}/start4.elf "$FIRMWARE/"
            cp ${rpiFw}/start4db.elf "$FIRMWARE/"
            cp ${rpiFw}/start4x.elf "$FIRMWARE/"
            cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin "$FIRMWARE/u-boot-rpi4.bin"
            cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin "$FIRMWARE/"
            cp ${configTxt} "$FIRMWARE/config.txt"
            echo "$NEW_HASH" > "$FIRMWARE/.nix-firmware-hash"
          fi
        else
          echo "rpi-firmware: /boot/firmware is not mounted" >&2
          exit 1
        fi
      '';
      deps = [ ];
    };

  systemd.settings.Manager = {
    WatchdogDevice = "/dev/watchdog0";
    RuntimeWatchdogSec = "30s";
    RebootWatchdogSec = "10m";
  };
}
