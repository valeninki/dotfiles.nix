{ pkgs }:

{
   environment.systemPackages = with pkgs; [
     zmem
     topmem
   ];
}
