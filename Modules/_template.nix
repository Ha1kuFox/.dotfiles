{
  config,
  lib,
  # pkgs,
  # inputs,
  ...
}: {
  # imports = [ ... ];

  config = lib.mkIf (lib.elem "NAME" config.mods) {
    # Тело модуля
  };
}
