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
      m1 = "ssh valen@100.88.192.17";
      w1 = "ssh valen@100.88.162.109";
      w2 = "ssh valen@100.108.49.113";
      "..." = "cd ../..";
    };
  };
}
