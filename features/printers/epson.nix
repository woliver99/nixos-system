# Adds drivers for printing/scanning to epson printers

{ pkgs, ... }:

{
  services.printing.drivers = [
    pkgs.epson-escpr # Epson
  ];

  hardware.sane.extraBackends = [
    pkgs.epsonscan2 # Epson
  ];
}
