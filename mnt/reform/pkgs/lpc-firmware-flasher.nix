{
  stdenv,
  lib,
  fetchFromGitLab,
  makeWrapper,
  lpc-firmware,
  systemdMinimal,
  coreutils,
  mount,
  boardRev,
}:

let
  sources = lib.importJSON ../sources.json;
  binName = "lpc-firmware-flasher-${boardRev}";
in
stdenv.mkDerivation {
  pname = binName;
  version = lpc-firmware.version;
  src = fetchFromGitLab sources.reform;
  sourceRoot = "source/reform2-lpc-fw";

  patchPhase = ''
    sed -E -i 's|(./)?bin/firmware.bin|${lpc-firmware}/bin/firmware.bin|g' flash.sh
  '';

  nativeBuildInputs = [ makeWrapper ];
  buildPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    install -m +x flash.sh $out/bin/${binName}
    wrapProgram $out/bin/${binName} \
      --prefix PATH : ${
        lib.makeBinPath [
          systemdMinimal
          coreutils
          mount
        ]
      }
  '';
  meta = {
    mainProgram = "${binName}";
  };
}
