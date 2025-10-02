{
  inputs,
  pkgs,
  unixpkgs,
  ...
}:

{
  imports = [ inputs.home-manager.nixosModules.default ];
  users = {
    mutableUsers = true;
    users.valentinus = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "libvirtd"
        "kvm"
        "wireshark"
      ];
      shell = pkgs.fish;
    };
  };
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs unixpkgs;
    };
    users.valentinus = import ./home;
  };
}
