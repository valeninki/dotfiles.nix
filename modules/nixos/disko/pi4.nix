{ lib, ... }:
{
  disko.devices = {
    disk = {
      SDCARD = {
        type = "disk";
        device = "/dev/mmcblk0";
        content = {
          type = "gpt";
          partitions = {
            BOOT = {
              priority = 1;
              name = "bootfs";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = [
                  "-F32"
                  "-n"
                  "bootfs"
                ];
                mountpoint = "/boot/firmware";
                mountOptions = [
                  "fmask=0022"
                  "dmask=0022"
                ];
              };
            };
            ROOT = {
              priority = 2;
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = [
                  "-L"
                  "rootfs"
                ];
                mountpoint = "/";
                mountOptions = [
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
  };
}
