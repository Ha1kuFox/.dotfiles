{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  config = lib.mkIf (lib.elem "noctalia" config.mods) {
    nix.settings = {
      extra-substituters = ["https://noctalia.cachix.org"];
      extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
      trusted-users = ["root" "@wheel"];
    };

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      recommendedServices.enable = true;
    };

    environment.systemPackages = [pkgs.hyprpicker];

    services.displayManager.noctalia-greeter = {
      enable = true;
      passwordlessSyncUsers = ["user"];
      settings = {
        cursor.size = 24;
        keyboard.layout = "us";
      };
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
      };
    };
  };
}
