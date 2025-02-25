# Firmware

Some firmware is required in order to run NixOS (or really Linux in general) to
the fullest extent on the Surface Pro 11. In particular, currently firmware is
used for Wi-Fi, Bluetooth, and some coprocessors.

As of 2025-02-25, the firmware is now automatically downloaded and updated from
[this GitHub repo][1], removing the need to manually extract and define the
path to the firmware. However, it's not currently included in the ISO installer
image due to fear of potential copyright and licensing issues.


## Setup

1. Set the following in your NixOS configuration:

   ```nix
   {
     hardware.surfacePro11.firmware.enable = true;
   }
   ```

2. Rebuild and reboot!


## Caveats

- If your drive is encrypted, the firmware won't be available until after you
  decrypt your root partition. The GPU kernel module also has some sort of
  timeout of around 5 seconds when looking for the firmware. This means that,
  **if you don't enter your password quickly, you will boot to a black
  screen**. This doesn't affect unencrypted or auto-decrypting partitions.

[1]: https://github.com/WOA-Project/Qualcomm-Reference-Drivers/tree/master/Surface/8380_DEN
