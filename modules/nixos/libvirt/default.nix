{
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["valentinus"];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
    };
    spiceUSBRedirection.enable = true;
  };
  
}

