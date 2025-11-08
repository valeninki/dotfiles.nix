{
  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = "";
      __fish_command_not_found_handler = {
        body = "__fish_default_command_not_found_handler $argv[1]";
        onEvent = "fish_command_not_found";
      };
      uclean = "nix-collect-garbage -d";
      clean = "sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
    };
    shellAliases = {
      k = "kubectl";
      "..." = "cd ../..";
    };
  };
}
