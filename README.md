NixOS on the Surface Pro 11
===========================

Based on the [excellent work by @dwhinham][1] that includes patches and tweaks
to get Linux running on the Surface Pro 11, which is in turn based on the
[custom Linux kernel by @jhovold][2] that has many patches for improved
Snapdragon X1E support. The modules themselves were inspired by [NixOS on Apple
Silicon][3].

Currently it is still very early days. Many things do not work (such as audio,
touchscreen, stylus, ...), however Wi-Fi, Bluetooth, and the GPU all work.


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


## Documentation

There is documentation on some of the requirements to set up things like the
firmware and Bluetooth, available [here](./docs/README.md). Read it carefully
before proceeding with installation, so you know what must be done in Windows
to set those up.

No detailed installation instructions for now, but people that are brave enough
should be able to figure out how to install it. This also serves as a barrier
so that you need technical knowledge to install it, so when things (inevitably)
break, hopefully you are more equipped to fix them :)

I will, however, offer some key points of advice that were painful to figure
out:

- Firstly, see the note about specifying the devicetree above to get the ISO to
  boot.

- Disable BitLocker in Windows before doing anything else, otherwise Windows
  will be bricked after you disable Secure Boot.

- Setting the USB boot option at the top of the boot priority is not enough to
  get it to boot, for whatever reason. When booting from the ISO many times,
  you have to hold Volume Up and swipe left on the USB option every time.

- **Do not delete the Windows partition**. If things go wrong, it makes it far
  easier to get back on your feet. Technically, you *can* delete it and use the
  [recovery image][4] if things go wrong (hint: use the serial number from the
  [iFixit teardown][5], `0F3746C24153KV`, to avoid entering your own), but it's
  far easier to just keep Windows around on a shrunk partition.

- **Use a flake for installation**. And make sure this module is included in
  the host's configuration, of course.


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


## Options

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


[1]: https://github.com/dwhinham/linux-surface-pro-11
[2]: https://github.com/jhovold/linux/tree/wip/x1e80100-6.13
[3]: https://github.com/tpwrules/nixos-apple-silicon
[4]: https://support.microsoft.com/en-us/surface-recovery-image
[5]: https://www.youtube.com/watch?v=Eg7KXJQ0p00&t=243
