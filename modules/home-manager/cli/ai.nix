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
          "opencode-mem@latest"
          "@kdcokenny/opencode-notify@latest"
          "@tarquinen/opencode-dcp@latest"
          "@slkiser/opencode-quota@latest"
        ];
        provider.commandcode = {
          npm = "@ai-sdk/openai-compatible";
          name = "CommandCode";
          options = {
            baseURL = "https://api.commandcode.ai/provider/v1";
            apiKey = "{env:CMD_API_KEY}";
          };
          models."deepseek/deepseek-v4-flash" = {
            name = "DeepSeek V4 Flash";
          };
        };
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
