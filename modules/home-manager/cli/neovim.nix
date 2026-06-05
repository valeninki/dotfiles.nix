{

  programs = {
    neovim = {
      enable = true;
      withRuby = true;
      withPython3 = true;
      extraConfig = ''
        set number
        set mouse=a
        set tabstop=4
      '';
    };
  };

}
