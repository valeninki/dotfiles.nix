{ ... }:

{
  services.awg-client = {
    enable = true;
    address = "10.20.51.3/32";
    privateKeySecret = "amneziawg/thinkpad_private_key";
  };
}
