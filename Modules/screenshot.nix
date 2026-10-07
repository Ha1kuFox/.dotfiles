{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "screenshot" config.mods) {
    environment.systemPackages = with pkgs; [hyprshot wl-clipboard];
  };
}
