{
  lib,
  callPackage,
  linuxPackagesFor,
  _kernelPatches ? [ ],
}:

let
  linux-jhovold-pkg = { stdenv, lib, fetchFromGitHub, fetchpatch, buildLinux, ... }@args:
    (buildLinux (args // {
      inherit stdenv lib;

      version = "6.13.0-jhovold";
      modDirVersion = "6.13.0";
      extraMeta.branch = "6.13";

      src = fetchFromGitHub {
        # tracking: https://github.com/dwhinham/kernel-surface-pro-11/tree/wip/x1e80100-6.13-sp11
        owner = "dwhinham";
        repo = "kernel-surface-pro-11";
        rev = "3c3b4ea67b523fc81db4b4793fbcb67cbd58208b";
        hash = "sha256-ENDsbQZm+rqNnjQGMpWI7Ehy3cP5m7YkLiN8gSZDpiY=";
      };

      kernelPatches = [
        {
          name = "wifi";
          patch = fetchpatch {
            url = "https://github.com/dwhinham/kernel-surface-pro-11/commit/fcc769be9eaa9823d55e98a28402104621fa6784.patch";
            hash = "sha256-NItJRJVY2Q38fjsgztpdO2cTltpuU2UDwCBybw7J7ng=";
          };
        }
      ] ++ _kernelPatches;
      extraConfig = ''
        IPV6_FOU_TUNNEL y
      '';

      defconfig = ./config;
    } // (args.argsOverride or {})));
  linux-jhovold = (callPackage linux-jhovold-pkg { });
in lib.recurseIntoAttrs (linuxPackagesFor linux-jhovold)
