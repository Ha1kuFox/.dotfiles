{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "hypr" config.mods) {
    programs = {
      hyprland = {
        enable = true;
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-hyprland];
      configPackages = [pkgs.hyprland];
    };

    environment.systemPackages = with pkgs; [
      kdePackages.polkit-kde-agent-1
      kdePackages.dolphin
      kdePackages.kdegraphics-thumbnailers # for images, pdf and .blend

      # Чтобы работал выбор файлов в некоторых прогах
      gsettings-desktop-schemas
    ];
  };
}
