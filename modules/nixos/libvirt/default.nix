{

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = [ "valentinus" ];

  virtualisation = {
    libvirtd = {
      enable = true;
      
    };
  };

}
