{
  inputs,
  ...
}:

{

  nixpkgs.overlays = [
    (final: prev: {
	  valenpkgs = inputs.valenpkgs.packages.${prev.stdenv.hostPlatform.system};
	})
  ];

}
