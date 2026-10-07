# cspenguin-wine: the same Kron4ek Wine 11.4 "amd64" build used by the
# upstream CSPenguin-Installer, prepared for NixOS:
#   - RPATHs of all ELF files point at the nix store (auto-patchelf).
#   - the CSPenguin 11.4 mfplat/winegstreamer patches are baked in the
#     store (the store is read-only, so they cannot be applied later).
#   - i386-unix ELF32 loaders/libs get a 32-bit interpreter + RPATH.
#   - $out/nix-support/gst-plugin-path lists the GStreamer plugin dirs
#     install.sh and the launchers use at runtime.
{pkgs}:
with pkgs; let
  version = "11.4";
  i686 = pkgsi686Linux;
  fetchPatch = url: sha256: fetchurl {inherit url sha256;};

  src = fetchurl {
    url = "https://github.com/Kron4ek/Wine-Builds/releases/download/${version}/wine-${version}-amd64.tar.xz";
    sha256 = "0gsjxjk7ws5359hqlp9bdswkliab5pg0iyi2ysizjp6vkqrn31xr";
  };

  patchBase = "https://raw.githubusercontent.com/parka6060/CSPenguin-Installer/main/patches";

  mfplat = fetchPatch "${patchBase}/x86_64-windows-wine${version}/mfplat.dll" "sha256-eiQv64vpKd+DW6e50vJwcunC+w1noC8eNwjEuWCtbzI=";
  mfreadwrite = fetchPatch "${patchBase}/x86_64-windows-wine${version}/mfreadwrite.dll" "sha256-qhVpquaYDELvX4kPo0AL019ILFgAP9zxNgHe7Hz55aM=";
  winegstreamerDll = fetchPatch "${patchBase}/x86_64-windows-wine${version}/winegstreamer.dll" "sha256-/O3xaI1XNUoehx9YijCZARl7eNmDm857XMUfGqPj/08=";
  winegstreamerSo = fetchPatch "${patchBase}/x86_64-unix-wine${version}/winegstreamer.so" "sha256-Qp8z3iVu3l0pckowFvatiO3r9rxEcGsKAoyTLcLL1a4=";

  mkGst = gst: [
    gst.gstreamer
    gst.gst-plugins-base
    gst.gst-plugins-good
    gst.gst-plugins-bad
    gst.gst-plugins-ugly
    gst.gst-libav
  ];

  gstPlugins = mkGst gst_all_1;

  # libraries the 64-bit wine binaries link against (DT_NEEDED) plus the
  # set wine dlopen()s at runtime (fonts, GL, vulkan, X, …).
  lib64 =
    [
      gcc-unwrapped.lib
      alsa-lib
      ffmpeg_4
      glib
      libgphoto2
      ocl-icd
      libpcap
      pcsclite
      libpulseaudio
      sane-backends
      libudev-zero
      libusb1
      wayland
      libxkbcommon
      freetype
      fontconfig
      zlib
      libpng
      libjpeg
      libtiff
      libxml2
      libGL
      libGLU
      libdrm
      libgbm
      vulkan-loader
      gnutls
      cups
      openssl
      ncurses
      libx11
      libxext
      libxrandr
      libxrender
      libxcursor
      libxi
      libxinerama
      libxxf86vm
      libxcomposite
      libxdamage
      libxfixes
      libxtst
      libxv
    ]
    ++ gstPlugins;

  # same set, 32-bit flavour (needed by the i386-unix half of wine).
  # plugin sets beyond core+base are only needed for plugin discovery at
  # runtime (64-bit CSP), so the 32-bit half only links core gstreamer.
  lib32 = [
    i686.gcc-unwrapped.lib
    i686.alsa-lib
    i686.ffmpeg_4
    i686.glib
    i686.libgphoto2
    i686.ocl-icd
    i686.libpcap
    i686.pcsclite
    i686.libpulseaudio
    i686.sane-backends
    i686.libudev-zero
    i686.libusb1
    i686.wayland
    i686.libxkbcommon
    i686.freetype
    i686.fontconfig
    i686.zlib
    i686.libpng
    i686.libjpeg
    i686.libtiff
    i686.libxml2
    i686.libGL
    i686.libGLU
    i686.libdrm
    i686.libgbm
    i686.vulkan-loader
    i686.gnutls
    i686.cups
    i686.openssl
    i686.ncurses
    i686.libx11
    i686.libxext
    i686.libxrandr
    i686.libxrender
    i686.libxcursor
    i686.libxi
    i686.libxinerama
    i686.libxxf86vm
    i686.libxcomposite
    i686.libxdamage
    i686.libxfixes
    i686.libxtst
    i686.libxv
    i686.gst_all_1.gstreamer
    i686.gst_all_1.gst-plugins-base
  ];

  libDir = p: lib.getOutput "lib" p + "/lib";
  lib64SearchPath = lib.makeLibraryPath lib64;
  lib32SearchPath = lib.makeLibraryPath lib32;

  # extra dirs appended to the RPATH of every file auto-patchelf touches so
  # runtime dlopen() of freetype/GL/vulkan/etc. resolves as well.
  appendRunpaths = map libDir lib64;

  gstPluginDirs = lib.concatStringsSep ":" (map (p: "${p}/lib/gstreamer-1.0") gstPlugins);

  # wine-internal NEEDED entries that must not be resolved against nixpkgs
  ignoreMissing = [
    "libcapi20.so.3" # obscure ISDN capi library, never used on NixOS
    "ntdll.so" # wine-internal, resolved via wine's own lib dir
    "win32u.so"
  ];
in
  stdenv.mkDerivation {
    pname = "cspenguin-wine";
    inherit version src;

    nativeBuildInputs = [
      autoPatchelfHook
      patchelf
      python3
    ];

    buildInputs = lib64 ++ lib32;

    autoPatchelfIgnoreMissingDeps = ignoreMissing;
    inherit appendRunpaths;

    dontStrip = true;

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -a . $out/

      # bake the CSPenguin patches (read-only store => applied at build time)
      local win="$out/lib/wine/x86_64-windows"
      local unix="$out/lib/wine/x86_64-unix"
      mkdir -p "$win" "$unix" $out/nix-support

      cp ${mfplat} "$win/mfplat.dll"
      cp ${mfreadwrite} "$win/mfreadwrite.dll"
      cp ${winegstreamerDll} "$win/winegstreamer.dll"
      cp ${winegstreamerSo} "$unix/winegstreamer.so"

      cat > $out/nix-support/gst-plugin-path <<EOF
      ${gstPluginDirs}
      EOF
      runHook postInstall
    '';

    postFixup = ''
          # auto-patchelf skips ELF32 files; give the i386-unix half a 32-bit
          # interpreter + RPATH so 32-bit Windows processes (winetricks verbs,
          # VC redist, WebView2 Evergreen, …) work too.
          local ld32=${i686.glibc}/lib/ld-linux.so.2
          local rp=${lib32SearchPath}
          local f
          while IFS= read -r -d ''' f; do
            if readelf -h "$f" 2>/dev/null | grep -q 'ELF32'; then
              if patchelf --print-interpreter "$f" >/dev/null 2>&1; then
                patchelf --set-interpreter "$ld32" --set-rpath "$rp" "$f" 2>/dev/null || true
              else
                patchelf --set-rpath "$rp" "$f" 2>/dev/null || true
              fi
            fi
          done < <(find "$out" -type f \( -name '*.so' -o -name 'wine' -o -name 'wine-preloader' \) -print0)

          # Fix 64-bit preloader for NixOS: Kron4ek's x86_64 preloader is PIE
          # with first LOAD at VirtAddr 0x0, which is blocked by
          # vm.mmap_min_addr=65536 on NixOS (SIGSEGV at 0x7ff...).
          # Move the first LOAD to 0x400000.
          python3 << 'PY'
      import struct, os
      p = os.path.join(os.environ['out'], "lib/wine/x86_64-unix/wine-preloader")
      with open(p, 'r+b') as f:
          data = bytearray(f.read())
          # ELF64 header: e_entry at 0x18 (8 bytes), e_phoff at 0x20 (8), e_phentsize 0x36 (2), e_phnum 0x38 (2)
          e_entry = struct.unpack_from('<Q', data, 0x18)[0]
          e_phoff = struct.unpack_from('<Q', data, 0x20)[0]
          e_phentsize = struct.unpack_from('<H', data, 0x36)[0]
          e_phnum = struct.unpack_from('<H', data, 0x38)[0]
          base = 0x400000
          for i in range(e_phnum):
              off = e_phoff + i * e_phentsize
              p_type, p_flags, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_align = struct.unpack_from('<IIQQQQQQ', data, off)
              if p_type == 1 and p_vaddr == 0:  # PT_LOAD at 0x0
                  # move to base
                  struct.pack_into('<QQ', data, off+16, base, base)  # p_vaddr, p_paddr
                  if e_entry < 0x10000:
                      struct.pack_into('<Q', data, 0x18, base + e_entry)
                  break
          f.seek(0)
          f.write(data)
      print("patched 64-bit preloader for NixOS mmap_min_addr")
      PY
          # NixOS: 64-bit preloader segfaults at 0x7ffe... with Kron4ek binary
          # (mmap_min_addr / ASLR incompat). Wine falls back to no-preloader
          # correctly and win64 prefix creation then succeeds (tested via bwrap).
          rm -f $out/lib/wine/x86_64-unix/wine-preloader
    '';

    meta = {
      description = "Kron4ek Wine ${version} amd64 with CSPenguin patches baked in (NixOS-friendly)";
      homepage = "https://github.com/Kron4ek/Wine-Builds";
      license = lib.licenses.lgpl21Plus;
      mainProgram = "wine";
    };
  }
