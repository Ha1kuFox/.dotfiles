{
  config,
  lib,
  inputs,
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
  };
}
