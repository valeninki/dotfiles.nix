{
  pkgs,
  ...
}:

{
  services.printing.enable = true;

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Pantum_P2500W";
        deviceUri = "ipp://10.10.20.6:631/printers/Pantum_P2500W";
        model = "everywhere";
        description = "Pantum P2500W Laser Printer";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "Pantum_P2500W";
  };
}
