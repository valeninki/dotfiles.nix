#{ valenpkgs, inputs, ... }:

{
#  imports = [ inputs.valenpkgs.flakeModule ];
#
#  environment.systemPackages = with valenpkgs; [
#    topmem
#    zmem
#  ];
}
