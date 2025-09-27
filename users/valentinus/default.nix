{ inputs, pkgs, unixpkgs, ... }:

{
  imports = [ inputs.home-manager.nixosModules.default ];
  users = {
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
    home-manager = {
      useGlobalPkgs = true;
      extraSpecialArgs = {
        inherit inputs unixpkgs;
      };
      users.valentinus = import ./home;
    };
  };
}
