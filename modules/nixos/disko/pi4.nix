{
  disk ? "/dev/mmcblk0",
  ...
}:
{
  disko.devices = {
    disk = {
      SDCARD = {
        type = "disk";
        device = disk;
        content = {
          type = "gpt";
          partitions = {
            bootfs = {
              priority = 1;
              name = "bootfs";
              size = "512M";
              type = "C12A7328-F81F-11D2-BA4B-00A0C93EC93B";
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
            rootfs = {
              priority = 2;
              name = "rootfs";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                extraArgs = [
                  "-L"
                  "rootfs"
                  "-E"
                  "lazy_itable_init=1,lazy_journal_init=1"
                ];
                mountpoint = "/";
                mountOptions = [
                  "noatime"
                  "nodiratime"
                  "commit=10"
                  "discard"
                ];
              };
            };
          };
        };
      };
    };
  };
}
