{ pkgs, ... }:

{

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = [ "valentinus" ];

  virtualisation = {
    libvirtd = {
      enable = true;

      qemu = {
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
            }).fd
          ];
        };
      };
    };
    spiceUSBRedirection.enable = true;
  };

  systemd.services.libvirtd.path = [ pkgs.nftables ];

}
