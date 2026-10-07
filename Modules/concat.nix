{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "concat" config.mods) {
    environment.systemPackages = [
      inputs.concat.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
