{

  programs = {
    fish = {
      enable = true;
      functions = {
        fish_greeting = "";
        __fish_command_not_found_handler = {
          body = "__fish_default_command_not_found_handler $argv[1]";
          onEvent = "fish_command_not_found";
        };
        uclean = "nix-collect-garbage -d";
        clean = "doas nix-collect-garbage -d && doas /run/current-system/bin/switch-to-configuration boot";
      };
      shellAliases = {
        rebuild = "doas nixos-rebuild switch --flake ~/.dots#(hostname)";
        k = "kubectl";
        f9s = "flux9s";
        dua = "dua interactive";
        tree = "eza --tree";
        "..." = "cd ../..";
      };
    };
  };

}
