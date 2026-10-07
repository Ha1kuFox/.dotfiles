{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "shell" config.mods) {
    environment.systemPackages = with pkgs; [
      tuckr
      adwsteamgtk
      wofi
    ];
  };
}
