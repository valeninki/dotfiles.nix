{
  pkgs,
  ...
}:

{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "svelte"
      "dockerfile"
      "docker-compose"
      "make"
    ];
    extraPackages = with pkgs; [
      nixd
      nil
    ];
    userSettings = {
      features = {
        copilot = false;
      };

      telemetry = {
        metrics = false;
      };

      vim_mode = false;
    };
  };
}
