{
  programs.fish = {
    shellAliases = {
      rebuild = "doas nixos-rebuild switch --flake ~/.dots#w1";
    };
  };
}
