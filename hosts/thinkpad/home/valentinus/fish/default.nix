{
  programs.fish = {
    shellAliases = {
      rebuild = "doas nixos-rebuild switch --flake ~/.dots#thinkpad";
      tree = "eza --tree";
    };
  };
}
