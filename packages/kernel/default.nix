# adapted from https://github.com/tpwrules/nixos-apple-silicon/blob/1f7bdbb82f6b9ec1d8d206e2c64d36f13bae91a1/apple-silicon-support/packages/linux-asahi/default.nix

{ lib
, callPackage
, writeText
, linuxPackagesFor
, _kernelPatches ? [ ]
}:

let
  i = builtins.elemAt;

  # parse <OPT> [ymn]|foo style configuration as found in a patch's extraConfig
  # into a list of k, v tuples
  parseExtraConfig = config:
    let
      lines =
        builtins.filter (s: s != "") (lib.strings.splitString "\n" config);
      parseLine = line: let
        t = lib.strings.splitString " " line;
        join = l: builtins.foldl' (a: b: "${a} ${b}")
          (builtins.head l) (builtins.tail l);
        v = if (builtins.length t) > 2 then join (builtins.tail t) else (i t 1);
      in [ "CONFIG_${i t 0}" v ];
    in map parseLine lines;

  # parse <OPT>=lib.kernel.(yes|module|no)|lib.kernel.freeform "foo"
  # style configuration as found in a patch's extraStructuredConfig into
  # a list of k, v tuples
  parseExtraStructuredConfig = config: lib.attrsets.mapAttrsToList
    (k: v: [ "CONFIG_${k}" (v.tristate or v.freeform) ] ) config;

  parsePatchConfig = { extraConfig ? "", extraStructuredConfig ? {}, ... }:
    (parseExtraConfig extraConfig) ++
    (parseExtraStructuredConfig extraStructuredConfig);

  # parse CONFIG_<OPT>=[ymn]|"foo" style configuration as found in a config file
  # into a list of k, v tuples
  parseConfig = config:
    let
      parseLine = builtins.match ''(CONFIG_[[:upper:][:digit:]_]+)=(([ymn])|"([^"]*)")'';
      # get either the [ymn] option or the "foo" option; whichever matched
      t = l: let v = (i l 2); in [ (i l 0) (if v != null then v else (i l 3)) ];
      lines = lib.strings.splitString "\n" config;
    in map t (builtins.filter (l: l != null) (map parseLine lines));

  origConfigfile = ./config;

  linux-jhovold-pkg = { stdenv, lib, fetchFromGitHub, fetchpatch, buildLinux, ... }:
    let
      origConfigText = builtins.readFile origConfigfile;

      # extraConfig from all patches in order
      extraConfig =
        lib.fold (patch: ex: ex ++ (parsePatchConfig patch)) [] _kernelPatches;
      # config file text for above
      extraConfigText = let
        text = k: v: if (v == "y") || (v == "m") || (v == "n")
          then "${k}=${v}" else ''${k}="${v}"'';
      in (map (t: text (i t 0) (i t 1)) extraConfig);

      # final config as a text file path
      configfile = if extraConfig == [] then origConfigfile else
        writeText "config" ''
          ${origConfigText}

          # Patches
          ${lib.strings.concatStringsSep "\n" extraConfigText}
        '';
      # final config as an attrset
      configAttrs = let
        makePair = t: lib.nameValuePair (i t 0) (i t 1);
        configList = (parseConfig origConfigText) ++ extraConfig;
      in builtins.listToAttrs (map makePair (lib.lists.reverseList configList));
    in
    (buildLinux {
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

      inherit configfile;
      config = configAttrs;
    });
  linux-jhovold = (callPackage linux-jhovold-pkg { });
in lib.recurseIntoAttrs (linuxPackagesFor linux-jhovold)
