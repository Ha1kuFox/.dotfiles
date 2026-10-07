{
  lib,
  flutter,
  fetchFromGitHub,
  buildGoModule,
  gtk3,
  libayatana-appindicator,
  keybinder3,
}: let
  version = "0.4.2";
  # Mihomo version from core/go.mod (also baked into lib/core_version.dart).
  coreVersion = "v1.19.28";

  src = fetchFromGitHub {
    owner = "pluralplay";
    repo = "FlClashX";
    rev = "v${version}";
    hash = "sha256-TBUBRG8I96QM0qhyugIOATJD9GwMGwakg0z8tFjIf0Y=";
  };

  # The mihomo-based core, built from core/ as a standalone executable.
  # Equivalent to `dart setup.dart linux --arch amd64 --out core` (CGO_ENABLED=0).
  clashCore = buildGoModule {
    pname = "flclashx-core";
    inherit version src;
    modRoot = "core";
    vendorHash = "sha256-BsFT/KrD8SX3edFtipK/eaJvVopvOCmTiw+Ydh+oa0s=";
    # setup.dart builds the core with CGO_ENABLED=0 (mode=core); with cgo the
    # empty lib.go/main_cgo.go build-tag set wins and produces a useless binary.
    env.CGO_ENABLED = 0;
    tags = ["with_gvisor"];
    ldflags = [
      "-w"
      "-s"
      "-X github.com/metacubex/mihomo/constant.Version=${coreVersion}"
    ];
    postInstall = ''
      mv $out/bin/core $out/bin/FlClashCore
    '';
  };
in
  flutter.buildFlutterApplication {
    pname = "flclashx";
    inherit version src;

    pubspecLock = lib.importJSON ./pubspec.lock.json;
    gitHashes = lib.importJSON ./git-hashes.json;

    flutterBuildFlags = [
      "--dart-define=APP_ENV=stable"
      "--dart-define=CORE_VERSION=${coreVersion}"
      "--dart-define=APP_VERSION=v${version}"
      "--target-platform=linux-x64"
    ];

    # linux/CMakeLists.txt installs libclash/linux/FlClashCore next to the app
    # binary; the app spawns it from there (lib/common/path.dart corePath).
    preBuild = ''
      mkdir -p libclash/linux
      cp ${clashCore}/bin/FlClashCore libclash/linux/FlClashCore
      chmod +x libclash/linux/FlClashCore
    '';

    buildInputs = [
      gtk3
      libayatana-appindicator
      keybinder3
    ];
    runtimeDependencies = [
      libayatana-appindicator
      keybinder3
    ];

    postInstall = ''
      install -Dm644 ${src}/assets/images/icon.png $out/share/icons/hicolor/256x256/apps/flclashx.png
      mkdir -p $out/share/applications
      cat > $out/share/applications/com.follow.clashx.desktop <<'EOF'
      [Desktop Entry]
      Type=Application
      Name=FlClashX
      GenericName=FlClashX
      Comment=Multi-platform proxy client based on Mihomo
      Exec=FlClashX
      Icon=flclashx
      Terminal=false
      Categories=Network;
      Keywords=FlClashX;Clash;Proxy;
      StartupNotify=true
      EOF
    '';

    passthru = {inherit clashCore;};

    meta = {
      description = "Fork of the multi-platform proxy client FlClash based on Mihomo core";
      homepage = "https://github.com/pluralplay/FlClashX";
      license = lib.licenses.gpl3;
      mainProgram = "FlClashX";
      platforms = lib.platforms.linux;
    };
  }
