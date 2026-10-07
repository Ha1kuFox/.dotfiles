{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  qt5,
  libusb1,
  libxtst,
  libxrandr,
}:
# Кастомный бамп xppen_4 до 4.0.15-260422 (Artist 16 3rd).
# Основан на pkgs/applications/misc/xppen/generic.nix из nixpkgs
# (там до сих пор 4.0.7-250117, который не знает 28bd:097e).
# Официальный тарболл: XPPenLinux4.0.15-260422.tar.gz от 23.04.2026.
stdenv.mkDerivation {
  pname = "xppen_4";
  version = "4.0.15-260422";

  src = fetchzip {
    name = "XPPenLinux4.0.15-260422.tar.gz";
    extension = "tar.gz";
    url = "https://download01.xp-pen.com/file/2026/04/XPPenLinux4.0.15-260422.tar.gz";
    hash = "sha256-vM1Lf2Nh/KqnENIZuhG8HehByv+XIukLtmpPlsIU9x0=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    libusb1
    libxtst
    libxrandr
  ];

  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;

  installPhase = ''
    runHook preInstall

    rm -r App/usr/lib/pentablet/{lib,platforms,PenTablet.sh}
    mkdir -p $out/{bin,usr}
    cp -r App/lib $out/lib
    cp -r App/usr/share $out/share
    cp -r App/usr/lib $out/usr/lib

    # hack: edit the binary directly
    # TODO: replace it with buildFHSEnv if possible? last time it caused other issues
    sed -i 's#/usr/lib/pentablet#/var/lib/pentablet#g' $out/usr/lib/pentablet/PenTablet
    ln -s $out/usr/lib/pentablet/PenTablet $out/bin/PenTablet

    substituteInPlace $out/share/applications/xppentablet.desktop \
      --replace-fail "/usr/lib/pentablet/PenTablet.sh" "PenTablet" \
      --replace-fail "/usr/share/icons/hicolor/256x256/apps/xppentablet.png" "xppentablet"

    runHook postInstall
  '';

  meta = {
    description = "XPPen driver";
    downloadPage = "https://www.xp-pen.com/download/";
    homepage = "https://www.xp-pen.com/";
    license = lib.licenses.unfree;
    mainProgram = "PenTablet";
    maintainers = with lib.maintainers; [
      gepbird
    ];
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}
