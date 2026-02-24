{

  programs.chromium = {
    enable = true;
    extraOpts = {
      "DnsOverHttpsMode" = "secure";
      "DnsOverHttpsTemplates" = "https://dns.valentinus.dev/dns-query";
    };
  };

}
