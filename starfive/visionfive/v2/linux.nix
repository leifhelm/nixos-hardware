{ lib, callPackage, linuxPackagesFor, kernelPatches, ... }:

let
  modDirVersion = "6.4.0-rc2";
  linuxPkg = { lib, fetchFromGitHub, buildLinux, ... }@args:
    buildLinux (args // {
      version = "${modDirVersion}-starfive-visionfive2";

      src = fetchFromGitHub {
        owner = "starfive-tech";
        repo = "linux";
        rev = "a09ac19e5900f54cb58b812067d35d07e666e56e";
        sha256 = "sha256-+NU1/AXtpXPVDu0o0wT40xDuRazk0KnrTpc0nbeMOKY=";
      };

      inherit modDirVersion;
      kernelPatches = [{ patch = ./fix-memory-size.patch; }] ++ kernelPatches;

      structuredExtraConfig = with lib.kernel; {
        PL330_DMA = no;
        SOC_STARFIVE = yes;
        PINCTRL_STARFIVE_JH7110_SYS = yes;
        SERIAL_8250_DW = yes;
      };

      extraMeta.branch = "JH7110_VisionFive2_upstream";
    } // (args.argsOverride or { }));

in lib.recurseIntoAttrs (linuxPackagesFor (callPackage linuxPkg { }))
