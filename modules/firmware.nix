{ config, pkgs, lib, ... }:
let
  cfg = config.hardware.surfacePro11;
  denali-firmware = pkgs.callPackage ../packages/firmware { inherit (cfg.firmware) path; };
in
{
  options.hardware.surfacePro11.firmware = {
    enable = lib.mkEnableOption "the firmware needed for the Surface Pro 11. Note that it must be supplied manually";
    path = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the firmware for the Surface Pro 11.

        Can be extracted with [this script][1].

        [1]: https://github.com/dwhinham/linux-surface-pro-11/blob/main/grab_fw.bat
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.firmware.enable) {
    hardware.firmware = [ denali-firmware ];
    # prevents display from shutting off if decryption password isn't entered fast enough
    # TODO: doesn't actually work...
    boot.initrd.extraFiles."lib/firmware/qcom/x1e80100/microsoft".source = "${denali-firmware}/lib/firmware/qcom/x1e80100/microsoft";
  };
}
