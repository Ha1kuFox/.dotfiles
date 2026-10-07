{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (lib.elem "firefox" config.mods) {
    programs.firefox.enable = true;
  };
}
