{ lib, ... }:
{
  disko.devices = {
    disk = {
      SDCARD = {
        type = "disk";
        device = "/dev/mmcblk0";
        content = {
          type = "table";
          format = "msdos";
          partitions = [
            {
              name = "bootfs";
              start = "1M";
              end = "512M";
              fs-type = "fat32";
              bootable = true;
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
            }
            {
              name = "rootfs";
              start = "512M";
              end = "100%";
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
            }
          ];
        };
      };
    };
  };
}
