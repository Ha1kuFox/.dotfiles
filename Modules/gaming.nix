{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # Per nixpkgs guidance conditional imports depending on `config` are not
  # allowed — import unconditionally and gate the effect with mkIf instead.
  # All current hosts enable "gaming", so behavior is unchanged.
  imports = [inputs.chaotic.nixosModules.default];

  config = lib.mkIf (lib.elem "gaming" config.mods) {
    chaotic.nyx.cache.enable = false;

    # Steam
    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      steam = {
        enable = true;
        gamescopeSession.enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
    };

    # Fix gamepads
    services = {
      udev = {
        packages = with pkgs; [
          game-devices-udev-rules
        ];
      };
    };
    hardware = {
      uinput.enable = true;
      steam-hardware.enable = true;
    };

    # Minecraft
    networking.firewall = {
      allowedUDPPorts = [4445 25565 24454 14613]; # LAN world broadcast
      allowedTCPPorts = [25565 14613 24454]; # LAN world connection
    };
    environment.systemPackages = with pkgs; [
      (prismlauncher.override {
        jdks = [
          temurin-bin-8
          temurin-bin-17
          temurin-bin-21
        ];
        additionalPrograms = [ffmpeg];
      })
      r2modman
    ];
  };
}
