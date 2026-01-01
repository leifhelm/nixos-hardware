{
  lib,
  callPackage,
}:
let
  boardRevisions = [
    "20_R3"
    "25_R2"
    "30_R1"
  ];
in
rec {
  lpcFirmware = lib.genAttrs boardRevisions (
    boardRev: callPackage ./lpc-firmware.nix { inherit boardRev; }
  );
  lpcFirmwareFlasher = lib.genAttrs boardRevisions (
    boardRev:
    callPackage ./lpc-firmware-flasher.nix {
      inherit boardRev;
      lpc-firmware = lpcFirmware."${boardRev}";
    }
  );
  reformFlashUboot =
    lib.mapAttrs (_name: config: callPackage ./reform-flash-uboot.nix { inherit config; })
      {
        reform2-rk3588-dsi = {
          warn = true;
          mmc = "mmcblk0";
          mmcBoot0 = false;
          ubootOffset = 32768;
          flashbinOffset = 0;
          image = "${ubootImage.reform2-rk3588-dsi}/rk3588-mnt-reform2-dsi-flash.bin";
        };
      };

  uboot.reform2-rk3588-dsi = callPackage ../rk3588/uboot.nix { };
  ubootImage.reform2-rk3588-dsi = callPackage ../rk3588/uboot-image.nix {
    uboot = uboot.reform2-rk3588-dsi;
  };
  keyboard4Firmware = lib.mergeAttrsList (
    lib.mapCartesianProduct
      (config: {
        "${config.kbdMode}-${config.kbdVariant}" = callPackage ./keyboard4-firmware.nix {
          inherit (config) kbdMode kbdVariant;
        };
      })
      {
        kbdMode = [
          "laptop"
          "standalone"
        ];
        kbdVariant = [
          "us"
          "intl"
        ];
      }
  );
}
