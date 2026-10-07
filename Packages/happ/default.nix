{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  zlib,
  fontconfig,
  freetype,
  libglvnd,
  mesa,
  libxkbcommon,
  libx11,
  libxcb,
  libXext,
  libXtst,
  libxcb-util,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  e2fsprogs,
  libgpg-error,
  openssl,
  dbus,
  glib,
  systemd,
  alsa-lib,
  xkeyboard-config,
  wayland,
  egl-wayland,
  libdrm,
}:
stdenv.mkDerivation rec {
  pname = "happ";
  version = "4.3.0";

  src = fetchurl {
    url = "https://github.com/Happ-proxy/happ-desktop/releases/download/${version}/Happ.linux.x64.deb";
    hash = "sha256-QchsDK8YGQvOWKf2A/1GbJ4/v+8rhfg3Y1oEU0Aa/7o=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    fontconfig
    freetype
    libglvnd
    mesa
    libxkbcommon
    libx11
    libxcb
    libXext
    libXtst
    libxcb-util
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    e2fsprogs
    libgpg-error
    openssl
    dbus
    glib
    systemd
    alsa-lib
    xkeyboard-config
    wayland
    egl-wayland
    libdrm
  ];

  # The .deb is `ar` archive, not a tarball nix knows how to unpack.
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    dpkg-deb -x $src unpack
    mkdir -p $out
    cp -r unpack/opt $out/opt
    chmod -R u+w $out/opt

    # Binaries keep their bundled layout ($out/opt/happ/{bin,lib} + qt.conf),
    # so Qt plugin/QML paths still resolve via $ORIGIN/../lib.
    # Wrappers (not symlinks) so we can inject LD_LIBRARY_PATH for
    # dlopen() deps like libssl/libcrypto used by the Qt TLS backend —
    # autoPatchelf only covers DT_NEEDED, not dlopen.
    mkdir -p $out/bin
    libPath="$out/opt/happ/lib:${lib.makeLibraryPath buildInputs}:/run/opengl-driver/lib"
    for bin in happd happ-diag happ-tcping; do
      makeWrapper $out/opt/happ/bin/$bin $out/bin/$bin \
        --prefix LD_LIBRARY_PATH : "$libPath" \
        --set XKB_CONFIG_ROOT "${xkeyboard-config}/share/X11/xkb"
    done
    # GUI: bundled Qt 6.11's GLES/EGL stack can't create an RHI context on
    # NixOS Mesa ("EGL not available" → SIGABRT), so default to the Qt Quick
    # software backend. Still overridable, e.g. QT_QUICK_BACKEND=rhi happ.
    makeWrapper $out/opt/happ/bin/Happ $out/bin/Happ \
      --prefix LD_LIBRARY_PATH : "$libPath" \
      --set XKB_CONFIG_ROOT "${xkeyboard-config}/share/X11/xkb" \
      --set-default QT_QUICK_BACKEND software
    ln -s $out/bin/Happ $out/bin/happ

    # Desktop entry (point Exec at the wrapper name, not /opt).
    mkdir -p $out/share/applications
    cat > $out/share/applications/Happ.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=Happ
    GenericName=Happ Proxy Client
    Comment=Happ Proxy Client (Xray-core, TUN/VPN mode)
    Exec=happ %f
    Icon=happ
    MimeType=application/x-happ;application/json;
    Categories=Utility;Network;
    Terminal=false
    StartupNotify=true
    EOF

    # Icons + mime from the .deb.
    mkdir -p $out/share/icons
    cp -r unpack/usr/share/icons/hicolor $out/share/icons/hicolor || true
    mkdir -p $out/share/mime/packages
    cp unpack/usr/share/mime/packages/happ-mime.xml $out/share/mime/packages/ || true

    # Systemd unit for the privileged daemon (used by Modules/happ.nix).
    # Upstream ExecStart=/opt/happ/bin/happd is rewritten to the store path.
    mkdir -p $out/lib/systemd/system
    sed "s#/opt/happ/bin/happd#$out/opt/happ/bin/happd#" \
      unpack/etc/systemd/system/happd.service > $out/lib/systemd/system/happd.service

    runHook postInstall
  '';

  # autoPatchelf appends nix-store RUNPATHs while keeping $ORIGIN/../lib,
  # so bundled Qt libs still win and only missing system libs resolve outward.
  # libQt6WlShellIntegration.so.6 is a known upstream packaging gap (the
  # wl-shell plugin references it but the .deb doesn't ship it; wl-shell is
  # legacy — xdg-shell is what matters on modern compositors).
  autoPatchelfIgnoreMissingDeps = [
    "libQt6WlShellIntegration.so.6"
  ];

  meta = {
    description = "Happ Proxy Client — user-friendly GUI client for xray-core with TUN/VPN mode (prebuilt binary)";
    homepage = "https://github.com/Happ-proxy/happ-desktop";
    license = lib.licenses.unfree;
    mainProgram = "happ";
    platforms = ["x86_64-linux"];
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
  };
}
