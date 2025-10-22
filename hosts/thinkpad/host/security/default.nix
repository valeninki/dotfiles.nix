{
  security = {
    polkit.enable = true;
    pam.services = {
      "login".fprintAuth = false;
      "swaylock".enable = true;
    };
  };
}
