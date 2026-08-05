{
  unixpkgs,
  ...
}:

{

  programs = {
    opencode = {
      enable = true;
      package = unixpkgs.opencode;
      enableMcpIntegration = true;
      settings = {
        plugin = [
          "opencode-mem"
          "opencode-antigravity-auth@latest"
          "opencode-copilot-enhanced@latest"
          "@tarquinen/opencode-dcp"
          "@slkiser/opencode-quota"
        ];
        mcp = {
          context7 = {
            type = "remote";
            url = "https://mcp.context7.com/mcp";
          };
          gh_grep = {
            type = "remote";
            url = "https://mcp.grep.app";
          };
        };
      };
    };
  };

}
