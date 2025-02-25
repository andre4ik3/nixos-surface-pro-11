{ config, pkgs, lib, ... }:
let
  cfg = config.hardware.surfacePro11;
  denali-firmware = pkgs.callPackage ../packages/firmware { };
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "hardware" "surfacePro11" "firmware" "path" ] "The firmware is now downloaded and extracted automatically.")
  ];

  options.hardware.surfacePro11.firmware = {
    enable = lib.mkEnableOption "the firmware needed for the Surface Pro 11";
  };

  config = lib.mkIf (cfg.enable && cfg.firmware.enable) {
    hardware.firmware = [ denali-firmware ];
  };
}
