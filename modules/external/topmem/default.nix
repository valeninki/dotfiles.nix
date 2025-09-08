{ pkgs, ... }:

let
  topmem = pkgs.stdenv.mkDerivation {
    pname = "topmem";
    version = "6b32afb";
    
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/CachyOS/CachyOS-Settings/refs/heads/master/usr/bin/topmem";
      sha256 = "1xhg90vrzddn61nglbq1f20kzhsrqp67jv2zd535h9w9byrmkhci";
    };
    
    buildInputs = [ 
      (pkgs.lua5_3.withPackages (ps: with ps; [ luv ] ))
    ];

    dontUnpack = true;
  
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/topmem
      chmod +x $out/bin/topmem
    '';
  };
in
{
  environment.systemPackages = [ topmem ];
}
