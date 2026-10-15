# PhotoCraft: desktop app + headless CLI, built from the local Ha1kuFox/photocraft
# checkout (personal fork with Noctalia theme, Paint Bucket extras, Studio
# options-bar parity). Adapted from makemake-kbo's upstream PR #621
# (nix/package.nix), minus the release packaging: no craft-fonts embedding
# (no checkout here; system CJK fonts are used), dev-build provenance.
#
# Rebuild after pulling the checkout: the source is filtered (no target/,
# .git/, corpus/), so only real source edits trigger a rebuild.
{
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  makeBinaryWrapper,
  desktop-file-utils,
  appstream,
  versionCheckHook,
  # Loaded at runtime with dlopen (winit, wgpu, rfd), so they are not ELF
  # NEEDED entries: same list as packaging/linux/nfpm.yaml.
  dbus,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  vulkan-loader,
  wayland,
  # Local checkout to build. Override with e.g.
  # `photocraft.override { srcDir = /other/checkout; }`.
  srcDir ? /home/user/Projects/photocraft,
}: let
  appId = "ai.storyteller.photocraft";
  src = lib.cleanSourceWith {
    src = srcDir;
    filter = name: _type: let
      base = baseNameOf (toString name);
    in
      !(builtins.elem base [
        ".git"
        "target"
        "corpus"
        "result"
        "log"
        "plan"
      ]);
  };
  version = (lib.importTOML (src + "/Cargo.toml")).workspace.package.version;
  runtimeLibraries = [
    dbus # libdbus-1.so.3: rfd's file dialogs talk to xdg-desktop-portal over D-Bus
    libGL # libEGL.so.1 (libglvnd)
    libx11 # libX11.so.6, libX11-xcb.so.1
    libxcb
    libxcursor
    libxi
    libxkbcommon # libxkbcommon.so.0
    vulkan-loader
    wayland # libwayland-client.so.0
  ];
in
  rustPlatform.buildRustPackage {
    pname = "photocraft";
    inherit src version;

    cargoLock = {
      lockFile = src + "/Cargo.lock";
      # Git dependencies need a hash; re-fetch with
      # `nix run nixpkgs#nix-prefetch-git -- --url <url> --rev <rev>`
      # when the workspace Cargo.toml moves a rev.
      outputHashes = {
        "craft-print-0.1.0" = "sha256-uXP0zITi8i1JDUyc451FmZ0Pl1ZK4D0rlTJQmGFVm0I=";
        "craft-ui-0.1.0" = "sha256-VhLeT7VLdZAIz6gR9PdFI34IJxHsGF8NE0uzFCN2vIU=";
        "craft-winprint-gdi-0.1.0" = "sha256-n1pcNaBGrnvSsE5MedeSRczJOMhfmF/LGFiiDTrG1GM=";
        "winprint-0.2.1" = "sha256-wnz/VbqQ3j/x1PEq6Elxu/oSjVqdONfqQmZ31NsTIIc=";
      };
    };

    nativeBuildInputs = [pkg-config] ++ lib.optionals stdenv.hostPlatform.isLinux [makeBinaryWrapper];

    buildInputs = lib.optionals stdenv.hostPlatform.isLinux runtimeLibraries;

    cargoBuildFlags = [
      "--package=photocraft"
      "--package=photocraft-cli"
    ];
    cargoTestFlags = [
      "--package=photocraft"
      "--package=photocraft-cli"
    ];
    # HEIC/HEIF import (heic-rs, pure Rust, no system libs): not default upstream,
    # but every official build enables it.
    buildFeatures = ["heif"];

    # NOTE: the cargo vendor step needs crates.io; if the sandbox has no DNS
    # that step fails and the build cannot proceed. The vendor dir is cached in
    # the store, so retrying usually gets past flaky downloads.
    postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
      install -Dm644 packaging/linux/${appId}.desktop -t $out/share/applications
      install -Dm644 packaging/linux/${appId}.mime.xml $out/share/mime/packages/${appId}.xml
      mkdir -p $out/share/metainfo $out/share/icons
      substitute packaging/linux/${appId}.metainfo.xml.in $out/share/metainfo/${appId}.metainfo.xml \
        --subst-var-by VERSION ${version} \
        --subst-var-by DATE "$(date -u -d "@$SOURCE_DATE_EPOCH" +%F)"
      cp -R assets/app-icon/hicolor $out/share/icons/
    '';

    # None of the runtime libraries is an ELF NEEDED entry (dlopen), so rpath them
    # explicitly; the start-up linker-cache check says nothing about this closure.
    postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
      patchelf --add-rpath ${lib.makeLibraryPath runtimeLibraries} $out/bin/photocraft
      patchelf --add-rpath ${lib.makeLibraryPath runtimeLibraries} $out/bin/photocraft-cli
      wrapProgram $out/bin/photocraft --set-default PHOTOCRAFT_SKIP_LIB_CHECK 1
    '';

    nativeInstallCheckInputs =
      [
        versionCheckHook
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        desktop-file-utils
        appstream
      ];
    doInstallCheck = true;
    versionCheckProgramArg = "--version";
    installCheckPhase =
      ''
        runHook preInstallCheck
      ''
      + lib.optionalString stdenv.hostPlatform.isLinux ''
        desktop-file-validate $out/share/applications/${appId}.desktop
        appstreamcli validate --no-net --explain $out/share/metainfo/${appId}.metainfo.xml
      ''
      + ''
        $out/bin/photocraft-cli --version
        runHook postInstallCheck
      '';

    meta = {
      description = "Open-source, native image editor that works the way Photoshop users expect";
      homepage = "https://getartcraft.com/apps/photocraft";
      license = [
        lib.licenses.mit
        lib.licenses.asl20
      ];
      mainProgram = "photocraft";
    };
  }
