{ lib, config, modulesPath, ... }:

{
  imports = [
    ./modules/default.nix
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  boot.supportedFilesystems.zfs = lib.mkForce false;
  hardware.enableAllHardware = lib.mkForce false; # Missing kernel modules in the jhovold kernel

  # Ideally should PR hardware.devicetree support in the ISO to nixpkgs
  isoImage.contents = [{
    source = "${config.hardware.deviceTree.kernelPackage}/dtbs";
    target = "/boot/dtbs/${config.hardware.deviceTree.kernelPackage.modDirVersion}";
  }];
}
