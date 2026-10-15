# PhotoCraft, built from the local Ha1kuFox/photocraft checkout
# (Packages/photocraft). Provides: the desktop app with its launcher entry,
# icons and MIME types, plus the headless photocraft-cli.
{
  config,
  lib,
  pkgs,
  ...
}: let
  photocraft = pkgs.callPackage ../Packages/photocraft {};
in {
  config = lib.mkIf (lib.elem "photocraft" config.mods) {
    environment.systemPackages = [photocraft];
  };
}
