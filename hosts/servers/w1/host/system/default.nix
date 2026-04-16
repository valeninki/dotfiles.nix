{
  pkgs,
  ...
}:

{
  environment = {
    systemPackages = with pkgs; [
      curl
      wget
      duperemove
      dmidecode
      iperf3
    ];
  };

}
