{
  inputs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
  ];

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
    };
  };
}
