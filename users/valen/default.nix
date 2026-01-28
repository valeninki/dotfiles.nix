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
    users.valen = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
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
    users.valen = import ./home;
  };
}
