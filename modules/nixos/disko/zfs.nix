_:

{
  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            swap = {
              size = "16G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };

            zpool = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };

      sataSSD = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TOSHIBA-TR200_498B63LYKBSN";
        content = {
          type = "gpt";
          partitions.sda1 = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "storage";
            };
          };
        };
      };
    };

    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          atime = "off";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "/";
          };

          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "/nix";
          };

          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "/home";
          };

          libvirt = {
            type = "zfs_fs";
            mountpoint = "/var/lib/libvirt";
            options.mountpoint = "/var/lib/libvirt";
          };

          incus = {
            type = "zfs_fs";
            mountpoint = "/var/lib/incus";
            options.mountpoint = "/var/lib/incus";
          };
        };
      };

      storage = {
        type = "zpool";
        rootFsOptions = {
          compression = "lz4";
          acltype = "posixacl";
          xattr = "sa";
          atime = "off";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          games = {
            type = "zfs_fs";
            mountpoint = "/data/Games";
            options = {
              mountpoint = "/data/Games";
              recordsize = "1M";
              compression = "lz4";
            };
          };

          vms = {
            type = "zfs_fs";
            mountpoint = "/data/VMs";
            options = {
              mountpoint = "/data/VMs";
              recordsize = "64K";
              compression = "off";
              atime = "off";
              primarycache = "metadata";
            };
          };

          backups = {
            type = "zfs_fs";
            mountpoint = "/data/Backups";
            options = {
              mountpoint = "/data/Backups";
              compression = "zstd";
              recordsize = "1M";
            };
          };
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /data/Games    0755 valentinus      users       - -"
    "d /data/Backups  0750 valentinus      users       - -"
    "d /data/VMs      2770 qemu-libvirtd   libvirtd    - -"
  ];
}
