{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/vda";
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
                mountOptions = [ "fmask=0022" "dmask=0022" ];
              };
            };
            luks = {
	      label = "luks";
	      device = "/dev/vda2";
              size = "100%";
	      content {
                type = "luks";
		name = "cryptroot";
		extraOpenArgs = [
                  "--allow-discards"
		  "--perf-no_read_workqueue"
		  "--perf-no-write_workqueue"
		];
	        settings = {crypttabExtraOpts = ["fido2-device=auto" "token-timeout=10"];};
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                    };
                    "/home" = {
		      mountpoint = "/home"; 
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
		      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd" "noatime"
                      ];
                    };
                  };
                };
              };
	    };
	    plainSwap = {
	      name = "swap";
	      device = "/dev/vda3";
	      size = "4G";
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
