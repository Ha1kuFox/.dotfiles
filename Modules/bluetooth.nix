{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (lib.elem "bluetooth" config.mods) {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
      };
    };

    services.blueman.enable = true;
  };
}
