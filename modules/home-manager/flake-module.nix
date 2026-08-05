{
  flake.homeModules = {
    cli = ./cli;
    apps = ./apps;
    desktop = ./desktop;

    full-desktop = {
      imports = [
        ./cli
        ./apps
        ./desktop
      ];
    };
  };
}
