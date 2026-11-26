# PhotoCraft: desktop app + headless CLI, built from the Ha1kuFox/photocraft
# fork (personal fork with Noctalia theme, Paint Bucket extras, Studio
# options-bar parity). Adapted from makemake-kbo's upstream PR #621
# (nix/package.nix), minus the release packaging: no craft-fonts embedding
# (no checkout here; system CJK fonts are used), dev-build provenance.
#
# The fork rev below is what the system builds: push to origin/main, then bump
# `rev` + `hash` here (`nix run nixpkgs#nix-prefetch-git -- --url
# https://github.com/Ha1kuFox/photocraft --rev <sha>`). For a dirty-checkout
# build without pushing: `photocraft.override { srcDir = /path/to/checkout; }`
# (needs `nixos-rebuild ... --impure` / `nix build --impure`).
{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
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
  # Local checkout to build instead of the pinned fork rev below, or null
  # for the pin. A path needs --impure (dirty tree is copied as-is).
  srcDir ? null,
}: let
  appId = "ai.storyteller.photocraft";
  src =
    if srcDir != null
    then
      lib.cleanSourceWith {
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
          ]);
      }
    else
      fetchFromGitHub {
        owner = "Ha1kuFox";
        repo = "photocraft";
        rev = "87c32f98e41123313a30a2900e43a9292c93e973";
        hash = "sha256-adSl4gvtwjJwkbDnAMohL71oq/GvuvJ6ONsb+0/Kfvc=";
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
        "craft-ai-agents-0.1.0" = "sha256-d/tJzTJVVDsVtBvpILMF3+eEDGTt9BEp71b2bB8cn7Q=";
        "craft-print-0.1.0" = "0zkq83638lys4g4kraznfhi77rwvnc7vs6x7ywfqjgcpvfyfqssg";
        "craft-ui-0.1.0" = "0zkq83638lys4g4kraznfhi77rwvnc7vs6x7ywfqjgcpvfyfqssg";
        "craft-winprint-gdi-0.1.0" = "sha256-HGJ4iAWJxBVXc9bSitSSOma2nqn35KgWs2ATHUyjX1E=";
        "winprint-0.2.1" = "sha256-32t8uIEiUHUzUYu4JowjFG8/CMvvFCdRgxd6mDBv0W4=";
        "ecolor-0.37.0" = "sha256-Kmgvc5FI1Of6576Xvdyp29LySN9JIZFrDXrCuuLxQrY=";
        "vectorcraft-geom-0.18.0" = "sha256-bX2yTI2K4Xk4YNoNcS2WxyjJyp09iVtEJlqV37fVytM=";
        "winit-0.30.13" = "sha256-+67bk7cqhM5VHqROL3PeghmhKJvlPIxhU73ay45vaxw=";
        "eframe-0.37.0" = "sha256-Kmgvc5FI1Of6576Xvdyp29LySN9JIZFrDXrCuuLxQrY=";
        "egui-0.37.0" = "sha256-Kmgvc5FI1Of6576Xvdyp29LySN9JIZFrDXrCuuLxQrY=";
        "egui-wgpu-0.37.0" = "sha256-Kmgvc5FI1Of6576Xvdyp29LySN9JIZFrDXrCuuLxQrY=";
        "egui-winit-0.37.0" = "sha256-Kmgvc5FI1Of6576Xvdyp29LySN9JIZFrDXrCuuLxQrY=";
        "egui_extras-0.37.0" = "sha256-Kmgvc5FI1Of6576Xvdyp29LySN9JIZFrDXrCuuLxQrY=";
        "egui_glow-0.37.0" = "sha256-Kmgvc5FI1Of6576Xvdyp29LySN9JIZFrDXrCuuLxQrY=";
        "egui_kittest-0.37.0" = "sha256-Kmgvc5FI1Of6576Xvdyp29LySN9JIZFrDXrCuuLxQrY=";
        "emath-0.37.0" = "sha256-Kmgvc5FI1Of6576Xvdyp29LySN9JIZFrDXrCuuLxQrY=";
        "epaint-0.37.0" = "sha256-Kmgvc5FI1Of6576Xvdyp29LySN9JIZFrDXrCuuLxQrY=";
        "epaint_default_fonts-0.37.0" = "sha256-Kmgvc5FI1Of6576Xvdyp29LySN9JIZFrDXrCuuLxQrY=";
        "vectorcraft-pathops-0.18.0" = "sha256-bX2yTI2K4Xk4YNoNcS2WxyjJyp09iVtEJlqV37fVytM=";
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
