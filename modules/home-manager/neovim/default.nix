{ pkgs, config, lib, ... }:

{
  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number
    '';
  };
}
