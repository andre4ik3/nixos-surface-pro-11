# Bluetooth

Bluetooth support on the Surface Pro 11 requires grabbing the hardware MAC
address of the device, as well as enabling the respective module.


## Setup

1. Reboot into Windows

2. Run the following command in `cmd`:

   ```
   ipconfig /all
   ```

3. Carefully note down the **Physical Address** of the following two adapters:

   - **Wireless LAN adapter Wi-Fi**
   - **Ethernet adapter Bluetooth Network Connection**

4. Reboot into NixOS, and add the following to your configuration:

   ```nix
   {
     hardware.surfacePro11.bluetooth = {
       enable = true;
       macAddress = "XX:XX:XX:XX:XX:XX"; // Physical Address of "Ethernet adapter Bluetooth Network Connection"
     };

     // This is technically optional. Personally I use `networking.networkmanager.wifi.macAddress = "stable-ssid"` and have a random MAC addres per network. But I recommend setting it anyway.
     hardware.surfacePro11.wireless = {
       enable = true;
       macAddress = "XX:XX:XX:XX:XX:XX"; // Physical Address of "Wireless LAN adapter Wi-Fi"
     };
   }
   ```

5. Rebuild and reboot!


## Caveats

- Currently, the Flex Keyboard cannot be used over Bluetooth. This is because
  there is [no way to pair the keyboard manually][1]. It relies on "magic"
  pairing, which only works in Windows.
  - Theoretically it could be possible to transfer the Bluetooth pairing keys
    from Windows to Linux, e.g. using a script [such as this one][2]. I tried
    this, but got stuck when I couldn't figure out the rest of the settings to
    put into the Bluetooth configuration file. But someone can try it and it
    could work. Maybe try pairing a different Bluetooth keyboard first, then
    overwrite it with the keys and MAC address of the Surface one?


[1]: https://support.microsoft.com/en-us/surface/use-surface-pro-flex-keyboard-13566b78-8afe-493f-a7b8-ebc51efb6e20
[2]: https://github.com/nbanks/bluetooth-dualboot
