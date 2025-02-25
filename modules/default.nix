{ config, pkgs, lib, ... }:

let
  # TODO: make a package overlay
  denali-kernel = pkgs.callPackage ../packages/kernel {
    _kernelPatches = config.boot.kernelPatches;
  };
  cfg = config.hardware.surfacePro11;
in

{
  imports = [
    ./networking.nix
    ./firmware.nix
  ];

  options.hardware.surfacePro11 = {
    enable = (lib.mkEnableOption "hardware support for the Surface Pro 11") // { default = true; };
    kernel.enable = (lib.mkEnableOption "the custom kernel needed to boot on the Surface Pro 11") // { default = cfg.enable; };
  };

  config = lib.mkIf (cfg.enable && cfg.kernel.enable) {
    hardware.deviceTree = {
      enable = true;
      name = "qcom/x1e80100-microsoft-denali.dtb";
    };

    boot.kernelPackages = denali-kernel;

    boot.crashDump.enable = lib.mkForce false; # doesn't work, prints kexec help message on boot

    # From nixos-hardware/microsoft/surface
    services.tlp.enable = false;
    services.iptsd.enable = true;
    hardware.sensor.iio.enable = true;

    boot.initrd.includeDefaultModules = false;
    boot.initrd.availableKernelModules = [
      # List of modules from:
      # https://github.com/dwhinham/linux-surface-pro-11/blob/main/build.sh
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
      "nvme"
      "nvmem_qcom_spmi_sdam"
      "pcie-qcom"

      # additional stuff necessary to boot off USB for the installer
      # and if the initrd (i.e. stage 1) goes wrong
      "usb-storage"
      "xhci-plat-hcd"
      "usbhid"
      "hid_generic"
      "hid_microsoft"
    ];

    boot.initrd.kernelModules = [
      # For LVM.
      "dm_mod"
    ];

    boot.kernelParams = [
      "mem_sleep_default=deep"
      "clk_ignore_unused"
      "pd_ignore_unused"
    ];
  };
}
