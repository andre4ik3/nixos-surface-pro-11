NixOS on the Surface Pro 11
===========================

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

