# Firmware

Some firmware is required in order to run NixOS (or really Linux in general) to
the fullest extent on the Surface Pro 11. The situation is similar to Asahi in
that the firmware must first be extracted, then set up in NixOS. In particular,
currently firmware is used for Wi-Fi, Bluetooth, and some coprocessors.


## Setup

1. Run [this script][1] in Windows. It will copy the necessary firmware into
   the `firmware` folder.

2. Zip up this folder and get it over to your Linux partition somehow. Some
   ideas on how you can do this:

   - Mount the Windows partition from within NixOS
   - Upload to a cloud service, then download
   - Copy to EFI partition

3. Unzip the directory in Linux, and add it to your Flake.

   - Make sure there is just one top-level directory, containing two
     subdirectories `qcom` and `ath12k`.
   - **The firmware is non-redistributable!** So don't push it anywhere public.

4. Set the following in your NixOS configuration:

   ```nix
   {
     hardware.surfacePro11.firmware = {
       enable = true;
       path = ./path/to/firmware;
     }; 
   }
   ```

5. Rebuild and reboot!


## Caveats

- If your drive is encrypted, the firmware won't be available until after you
  decrypt your root partition. The GPU kernel module also has some sort of
  timeout of around 5 seconds when looking for the firmware. This means that,
  **if you don't enter your password quickly, you will boot to a black
  screen**. This doesn't affect unencrypted or auto-decrypting partitions.
- For now, the aDSP firmware is ignored, as it causes USB devices to disconnect
  during boot.


## Future Work

It would be nice to evolve the script to copy the firmware over to the EFI
directory, then have a script that auto-extracts it on boot. This would remove
the need for keeping the firmware in the flake, however it would introduce a
possible attack vector for encrypted systems, as the firmware is sitting
unencrypted in the EFI partition.


[1]: https://github.com/dwhinham/linux-surface-pro-11/blob/main/grab_fw.bat
