{ ... }:

{
  services.awg-client = {
    enable = true;
    address = "10.20.51.2/32";
    privateKeySecret = "amneziawg/desktop_private_key";
  };
}
