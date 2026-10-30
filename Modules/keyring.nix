{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "keyring" config.mods) {
    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [
      libsecret
    ];
  };
}
