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
        rev = "fcc769be9eaa9823d55e98a28402104621fa6784";
        hash = "sha256-tIFflNcUaRGDI3LMLr1BS2m+7NZ7rV8Gob50OFQqxJ8=";
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
