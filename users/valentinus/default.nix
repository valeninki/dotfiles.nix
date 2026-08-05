{
  inputs,
  pkgs,
  unixpkgs,
  ...
}:

{
  users = {
    mutableUsers = true;
    users.valentinus = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "video"
        "network"
        "libvirtd"
        "kvm"
        "wireshark"
      ];
      shell = pkgs.fish;
    };
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs unixpkgs;
    };
    users.valentinus = import ./home;
  };
}
