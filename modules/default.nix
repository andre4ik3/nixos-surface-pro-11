{ config, pkgs, lib, ... }:

let
  # TODO: is it redistributable? probably not, need a setup similar to asahi
  #juno-firmware = pkgs.callPackage ./juno-firmware { };
  juno-kernel = pkgs.callPackage ../packages/kernel {
    _kernelPatches = config.boot.kernelPatches;
  };
in

{
  # TODO: make this into a real module, with configuration and things

  config = {
    hardware.deviceTree = {
      enable = true;
      name = "qcom/x1e80100-microsoft-denali.dtb";
    };

    #hardware.firmware = [ juno-firmware ];
    boot.kernelPackages = juno-kernel;

    boot.crashDump.enable = lib.mkForce false; # doesn't work, prints kexec help message on boot

    # prevents display from shutting off if decryption password isn't entered fast enough
    # TODO: doesn't actually work...
    #boot.initrd.extraFiles."lib/firmware/qcom/x1e80100/microsoft".source = "${juno-firmware}/lib/firmware/qcom/x1e80100/microsoft";

    # From nixos-hardware/microsoft/surface
    services.tlp.enable = false;
    services.iptsd.enable = true;
    hardware.sensor.iio.enable = true;

    #boot.initrd.includeDefaultModules = false;
    boot.initrd.availableKernelModules = [
      "tcsrcc-x1e80100"
      "phy-qcom-qmp-pcie"
      "phy-qcom-qmp-usb"
      "phy-qcom-qmp-usbc"
      "phy-qcom-eusb2-repeater"
      "phy-qcom-snps-eusb2"
      "phy-qcom-qmp-combo"
      "surface-hid"
      "surface-aggregator"
      "surface-aggregator-registry"
      "surface-aggregator-hub"

      # Without these, the NVMe drive won't be detected on boot.
      "nvmem_qcom_spmi_sdam"
      "pcie-qcom"
    ];

    boot.kernelParams = [
      "mem_sleep_default=deep"
      "clk_ignore_unused"
      "pd_ignore_unused"
    ];
  };
}
