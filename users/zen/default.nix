{
  config,
  pkgs,
  ...
}:

{

  users = {
    users = {
      zen = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "systemd-journal"
        ];
        shell = pkgs.fish;
      };
    };
  };

}
