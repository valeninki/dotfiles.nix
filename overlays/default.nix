self: super: {
  python3 = super.python3.override {
    packageOverrides = self: super: {
      tkinter = super.tkinter.overrideAttrs (oldAttrs: rec {
        buildInputs = oldAttrs.buildInputs // [ super.tcl_8_6 super.tk_8_6 ];
      });
    };
  };
}

