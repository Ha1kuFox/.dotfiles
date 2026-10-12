{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "system" config.mods) {
    # NIX
    nix.settings.experimental-features = ["nix-command" "flakes"];
    nixpkgs.config.allowUnfree = true;
    # NETWORK
    networking.networkmanager.enable = true;
    # USER
    users.users.user = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # can use sudo
        "render" # gpu access
        "networkmanager" # for nmcli
        "input" # For gamepads
      ];
    };

    # SECURITY
    security.polkit.enable = true;

    # BOOT
    boot = {
      consoleLogLevel = 0;
      kernelParams = [
        "quiet"
        "splash"
        "console=/dev/null"
      ];
      loader = {
        timeout = 0;
        systemd-boot = {
          enable = true;
          configurationLimit = 5;
          consoleMode = "max";
          editor = false;
        };
        efi.canTouchEfiVariables = true;
      };
      plymouth.enable = true;
    };

    # SOUND
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # FONTS
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
    fonts.fontconfig.defaultFonts = {
      monospace = ["JetBrainsMono Nerd Font Mono"];
      sansSerif = ["JetBrainsMono Nerd Font Mono"];
      serif = ["JetBrainsMono Nerd Font Mono"];
    };

    # COMMON
    time.timeZone = "Asia/Omsk";
    system.stateVersion = lib.mkDefault "26.05";
  };
}
