{ disk }:

{
  disko.devices.disk.sdCard = {
    type = "disk";
    device = disk;

    content = {
      # Raspberry Pi firmware is most broadly compatible with this layout.
      type = "table";
      format = "msdos";

      partitions = [
        {
          name = "firmware";
          part-type = "primary";
          start = "8MiB";
          end = "520MiB";
          fs-type = "fat32";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/firmware";
            mountOptions = [
              "defaults"
              "noatime"
            ];
            extraArgs = [
              "-F"
              "32"
              "-n"
              "FIRMWARE"
            ];
          };
        }

        {
          name = "root";
          part-type = "primary";
          start = "520MiB";
          end = "100%";
          fs-type = "ext4";
          bootable = true;

          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = [
              "defaults"
              "noatime"
            ];
            extraArgs = [
              "-L"
              "NIXOS_SD"
            ];
          };
        }
      ];
    };
  };
}
