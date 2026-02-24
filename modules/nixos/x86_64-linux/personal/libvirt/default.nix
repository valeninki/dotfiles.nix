{
  pkgs,
  ...
}:

{

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = [ "valentinus" ];

  virtualisation = {
    libvirtd = {
      enable = true;
    };
    spiceUSBRedirection.enable = true;
  };

  systemd.services.libvirtd.path = [ pkgs.nftables ];

}
