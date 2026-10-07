# Clip Studio Paint on NixOS via the CSPenguin-Installer (Kron4ek Wine 11.4).
# Provides: the patched wine (Packages/cspenguin/wine.nix) + the runtime
# ecosystem the installer/launchers need (download, archive, DE integration,
# GStreamer media stack, winetricks).
#
# The actual installation UI lives at Packages/cspenguin/install.sh (NixOS
# fork of CSPenguin-Installer) and is run manually by the user.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cspenguin-wine = pkgs.callPackage ../Packages/cspenguin/wine.nix {};
in {
  config = lib.mkIf (lib.elem "cspenguin" config.mods) {
    boot.kernel.sysctl."vm.mmap_min_addr" = 4096;

    environment.systemPackages = with pkgs; [
      cspenguin-wine

      # installer/cli requirements (checked by install.sh)
      wget
      curl
      zstd
      wmctrl
      xprop
      file
      cabextract
      unzip
      p7zip
      desktop-file-utils
      shared-mime-info
      gtk3
      winetricks

      # GStreamer stack used by the patched winegstreamer/mfplat (h264 mp4 I/O)
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav

      # 32-bit GStreamer so x86 (WebView2 Evergreen) processes can use media too
      pkgsi686Linux.gst_all_1.gstreamer
      pkgsi686Linux.gst_all_1.gst-plugins-base
      pkgsi686Linux.gst_all_1.gst-plugins-good
      pkgsi686Linux.gst_all_1.gst-libav
    ];
  };
}
