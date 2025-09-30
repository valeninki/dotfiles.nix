{
  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = "";
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
