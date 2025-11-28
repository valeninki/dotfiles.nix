{
  programs.fish = {
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/.dots#thinkpad";
      tree = "eza --tree";
    };
  };
}
