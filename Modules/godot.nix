{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "godot" config.mods) {
    environment.systemPackages = with pkgs; [
      godot
      blockbench
    ];
  };
}
