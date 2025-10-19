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
    users.test = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
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
    users.test = import ./home;
  };
}
