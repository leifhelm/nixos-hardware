{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  cmake,
  pico-sdk,
  gcc-arm-embedded,
  gcc,
  python3,
  picotool,
  kbdMode ? "laptop",
  kbdVariant ? "us",
}:
let
  sources = lib.importJSON ../sources.json;
  pico-sdk-with-submodules = pico-sdk.override { withSubmodules = true; };
in
assert lib.assertOneOf "kbdMode" kbdMode [
  "laptop"
  "standalone"
];
assert lib.assertOneOf "kbdVariant" kbdVariant [
  "us"
  "intl"
];
stdenvNoCC.mkDerivation rec {
  pname = "reform2-keyboard4-fw";
  version = sources.reformVersion;

  src = fetchFromGitLab sources.reform;
  sourceRoot = "source/reform2-keyboard4-fw";

  env = {
    PICO_SDK_PATH = "${pico-sdk-with-submodules}/lib/pico-sdk";
  };
  cmakeFlags = [
    (lib.cmakeOptionType "filepath" "CMAKE_C_COMPILER" "${gcc-arm-embedded}/bin/arm-none-eabi-gcc")
    (lib.cmakeOptionType "filepath" "CMAKE_CXX_COMPILER" "${gcc-arm-embedded}/bin/arm-none-eabi-g++")
    (lib.cmakeFeature "FAMILY" "rp2040")
    (lib.cmakeFeature "KBD_MODE" "KBD_MODE_${lib.toUpper kbdMode}")
    (lib.cmakeFeature "KBD_VARIANT" "KBD_VARIANT_${lib.toUpper kbdVariant}")
    (lib.cmakeFeature "KBD_HID_FW_REV" version)
  ];

  nativeBuildInputs = [
    cmake
    python3
    pico-sdk-with-submodules
    picotool
    gcc-arm-embedded
  ];

  installPhase = ''
    runHook preInstall
    install -Dt $out reform2-keyboard4-fw.bin
    runHook postInstall
  '';
}
