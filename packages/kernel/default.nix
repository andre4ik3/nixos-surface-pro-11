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

      version = "6.14.0-rc3-jhovold";
      modDirVersion = "6.14.0-rc3-jhovold";
      extraMeta.branch = "6.14-rc3";

      src = fetchFromGitHub {
        # tracking: https://github.com/dwhinham/kernel-surface-pro-11/tree/wip/x1e80100-6.14-rc3-sp11
        owner = "dwhinham";
        repo = "kernel-surface-pro-11";
        rev = "577543b779b22acf31c8df484bd09171aa71a9d3";
        hash = "sha256-rWtKcbeqSIneigLT1Uebw7nNvvJISMwxi9lqPZ6dlgs=";
      };

      kernelPatches = _kernelPatches;

      defconfig = "johan_defconfig";
      ignoreConfigErrors = true;

      # tracking: https://github.com/dwhinham/linux-surface-pro-11/blob/main/kernel_config_fragment
      extraConfig = ''
        FTRACE n
        LOCALVERSION -jhovold
        LOCALVERSION_AUTO n
        ACPI y
        BATTERY_SURFACE m
        CHARGER_SURFACE m
        SENSORS_SURFACE_FAN m
        SENSORS_SURFACE_TEMP m
        SURFACE_PLATFORMS y
        SURFACE_AGGREGATOR m
        SURFACE_AGGREGATOR_CDEV m
        SURFACE_AGGREGATOR_HUB m
        SURFACE_AGGREGATOR_REGISTRY m
        SURFACE_AGGREGATOR_TABLET_SWITCH m
        SURFACE_PLATFORM_PROFILE m
        SURFACE_HID m
        SURFACE_KBD m
        SPI_HID m
      '';
    } // (args.argsOverride or {})));
  linux-jhovold = (callPackage linux-jhovold-pkg { });
in lib.recurseIntoAttrs (linuxPackagesFor linux-jhovold)
