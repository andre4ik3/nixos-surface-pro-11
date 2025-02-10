{
  lib,
  callPackage,
  linuxPackagesFor,
  _kernelPatches ? [ ],
}:

let
  linux-jhovold-pkg = { stdenv, lib, fetchFromGitHub, buildLinux, ... }@args:
    (buildLinux (args // {
      inherit stdenv lib;

      version = "6.13.0-jhovold";
      modDirVersion = "6.13.0";
      extraMeta.branch = "6.13";

      src = fetchFromGitHub {
        # tracking: https://github.com/dwhinham/kernel-surface-pro-11/tree/wip/x1e80100-6.13-sp11
        owner = "dwhinham";
        repo = "kernel-surface-pro-11";
        rev = "81e7630cc416e88f541daba85c402ce2627071cd";
        hash = "sha256-THjV2hg98OhN2XW3yo5bKc1vXBv/bZnEZGoHi/qnJ2g=";
      };

      kernelPatches = _kernelPatches;

      defconfig = ./config;
      ignoreConfigErrors = true;
      extraConfig = ''
        FTRACE n
        SPI_HID m
      '';
    } // (args.argsOverride or {})));
  linux-jhovold = (callPackage linux-jhovold-pkg { });
in lib.recurseIntoAttrs (linuxPackagesFor linux-jhovold)
