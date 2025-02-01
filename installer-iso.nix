{ lib, modulesPath, ... }:

{
  imports = [
    ./modules/default.nix
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  boot.supportedFilesystems.zfs = lib.mkForce false;
}
