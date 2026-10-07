{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "v2raya" config.mods) {
    services.v2raya = {
      enable = true;
      cliPackage = pkgs.xray;
    };
  };
}
