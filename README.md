NixOS on the Surface Pro 11
===========================

## Installer

To build the installer ISO:

```
nix build -L github:andre4ik3/nixos-surface-pro-11#installer-iso
```

Note that, in order to boot the installer ISO, currently you have to press `e`
on the boot screen, and add the following line to the GRUB configuration (note
the two spaces before the line):

```
  devicetree /boot/dtbs/6.13.0/qcom/x1e80100-microsoft-denali.dtb
```

This is because currently the GRUB configuration is hardcoded in nixpkgs.
Eventually I will make a PR to nixpkgs for the ISO image to support
devicetrees, so that this workaround isn't needed.

## Modules

You can use it as a flake input, then use the `surface-pro-11` NixOS module:

```nix
{
  inputs = {
    nixpkgs = ...;
    # ...
    surface-pro-11 = {
      url = "github:andre4ik3/nixos-surface-pro-11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ...
  };

  outputs = { nixpkgs, surface-pro-11, ... }: {
    nixosConfigurations.foobar = nixpkgs.lib.nixosSystem {
      modules = [
        # ... your other stuff ...
        surface-pro-11.nixosModules.default
        # ... your other stuff ...
      ];
    };
  };
}
```

Then you can use the following options:

- `hardware.surfacePro11.enable`: master toggle, enabled by default. Disabling
  will disable everything else.

- `hardware.surfacePro11.kernel.enable`: enables building the custom kernel
  necessary for boot, as well as setting the needed kernel parameters and
  modules. Enabled by default.

- `hardware.surfacePro11.firmware.enable`: enables firmware (off by default)

- `hardware.surfacePro11.firmware.path`: path to the firmware

- `hardware.surfacePro11.wireless.enable`: enables Wi-Fi (off by default)

- `hardware.surfacePro11.wireless.macAddress`: sets MAC address for Wi-Fi

- `hardware.surfacePro11.bluetooth.enable`: enables Bluetooth (off by default)

- `hardware.surfacePro11.bluetooth.macAddress`: sets MAC address for bluetooth

