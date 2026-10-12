{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ./modules.nix
  ];

  programs.steam = {
    gamescopeSession.env = {
      DISABLE_HDR_WSI = "1";
      MESA_VK_WSI_PRESENT_MODE = "fifo";
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";
    };
    package = pkgs.steam.override {
      extraEnv = {
        DRI_PRIME = "1";
        AMD_VULKAN_ICD = "RADV";
        RADV_PERFTEST = "gpl";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    pciutils
  ];
}
