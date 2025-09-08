{ pkgs, ... }:

let
  zmemPkg = pkgs.rustPlatform.buildRustPackage rec {
    pname = "zmem";
    version = "140d37e";
  
    src = pkgs.fetchFromGitHub {
      owner = "xeome";
      repo = pname;
      rev = version;
      sha256 = "sha256-qn/xfw/p2b6A2pyiTaxS7Nlu5Gk8D7qTDDQfJ+3BzDQ=";
    };
  
    cargoHash = "sha256-pkBjVybga4yUmy8jpUfYi9i8eeRU2sIFEweDZLffP4o=";
  
    meta = {
      description = "Advanced linux memory monitoring.";
      homepage = "https://github.com/xeome/zmem";
    };
  };
in 
  {
  environment.systemPackages = [ zmemPkg ];
  }
