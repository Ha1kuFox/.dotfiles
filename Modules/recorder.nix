{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "recorder" config.mods) {
    environment.systemPackages = with pkgs; [
      wl-screenrec
    ];
  };
}
