{
  stdenvNoCC,
  lib,
  fetchFromGitLab,
  gcc,
  gcc-arm-embedded,
  boardRev,
}:
let
  sources = lib.importJSON ../sources.json;
in
stdenvNoCC.mkDerivation rec {
  pname = "refrom2-lpc-firmware-${boardRev}";
  version = sources.reformVersion;

  src = fetchFromGitLab sources.reform;
  sourceRoot = "source/reform2-lpc-fw";

  depsBuildBuild = [ gcc ];
  nativeBuildInputs = [ gcc-arm-embedded ];

  buildFlags = "lpcrc firmware";
  preBuild = ''
    makeFlagsArray+=(REFORM_LPC_OPTIONS='-DREFORM_MOTHERBOARD_REV=REFORM_MBREV_${boardRev} -DFW_STRING3=\"${version}\"')
  '';

  installPhase = ''
    runHook preInstall
    install -Dt $out/bin bin/firmware.bin
    runHook postInstall
  '';
}
