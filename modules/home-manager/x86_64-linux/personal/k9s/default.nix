{
  config,
  lib,
  unixpkgs,
  ...
}:

{
  programs.k9s = {
    enable = true;
    package = unixpkgs.k9s;
  };
}
