_:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            luks = {
              device = "/dev/nvme0n1p2";
              size = "444G";
              content = {
                type = "luks";
                name = "crypt";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "subvol=root"
                        "compress=zstd"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "subvol=home"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix/store" = {
                      mountpoint = "/nix/store";
                      mountOptions = [
                        "subvol=nix/store"
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
            plainSwap = {
              name = "swap";
              device = "/dev/nvme0n1p3";
              size = "100%";
              content = {
                type = "swap";
              };
            };
          };
        };
      };
    };
  };
}
