{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
          in {
            installer-iso = installer-system.config.system.build.isoImage;
          });

      };
}
