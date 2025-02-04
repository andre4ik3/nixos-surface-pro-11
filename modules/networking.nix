{ config, pkgs, lib, ... }:

let
  cfg = config.hardware.surfacePro11;
in
{
  options.hardware.surfacePro11 = {
    wireless = {
      enable = lib.mkEnableOption "Wi-Fi support on the Surface Pro 11";
      macAddress = lib.mkOption {
        type = lib.types.str;
        example = "AA:BB:CC:DD:EE:FF";
        description = ''
          The MAC address to use when configuring Wi-Fi. Should match the MAC
          address recorded in Windows, but can be any valid MAC address.
        '';
      };
    };
    bluetooth = {
      enable = lib.mkEnableOption "Bluetooth support on the Surface Pro 11";
      macAddress = lib.mkOption {
        type = lib.types.str;
        example = "AA:BB:CC:DD:EE:FF";
        description = ''
          The MAC address to use when configuring Bluetooth. Should match the
          MAC address recorded in Windows, but can be any valid MAC address.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (cfg.wireless.enable || cfg.bluetooth.enable) {
      assertions = [{
        assertion = cfg.firmware.enable;
        message = ''
          Wi-Fi and Bluetooth support on the Surface Pro 11 require firmware.
        '';
      }];
    })

    (lib.mkIf cfg.wireless.enable {
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="net", KERNELS=="0006:01:00.0", \
          RUN+="${pkgs.iproute2}/bin/ip link set dev wlP6p1s0 address ${cfg.wireless.macAddress}"
      '';
    })

    (lib.mkIf cfg.bluetooth.enable {
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="bluetooth", ENV{DEVTYPE}=="host" \
          ENV{DEVPATH}=="*/serial[0-9]*/serial[0-9]*/bluetooth/hci[0-9]*", \
          TAG+="systemd", ENV{SYSTEMD_WANTS}="hci-btaddress@%k.service"
      '';
      systemd.services."hci-btaddress@" = {
        description = "HCI bluetooth address fix";
        script = ''
          sleep 5 && yes | ${pkgs.bluez}/bin/btmgmt -i %I public-addr "${cfg.bluetooth.macAddress}"
        '';
      };
    })
  ]);
}
