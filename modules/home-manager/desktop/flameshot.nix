{
  pkgs,
  ...
}:

{

  services = {
    flameshot = {
      enable = true;
      package = pkgs.flameshot.override { enableWlrSupport = true; };
      settings = {
        General = {
          useGrimAdapter = true;
          showStartupLaunchMessage = false;
        };
      };
    };
  };

}
