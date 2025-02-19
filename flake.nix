{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "aarch64-linux" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
      {
        nixosModules = rec {
          surface-pro-11 = ./modules/default.nix;
          default = surface-pro-11;
        };

        packages = forAllSystems (system:
          let
            pkgs = import nixpkgs {
              crossSystem.system = "aarch64-linux";
              localSystem.system = system;
            };
            installer-system = nixpkgs.lib.nixosSystem {
              system = "aarch64-linux";
              modules = [ ./installer-iso.nix ];
              inherit pkgs;
            };
          in rec {
            installer-iso = installer-system.config.system.build.isoImage;
            kernelPackages = pkgs.callPackage ./packages/kernel { };
            kernel-config = kernelPackages.kernel.configfile;
            firmware = pkgs.callPackage ./packages/firmware { };
          });
      };
}
