{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ./modules.nix
  ];

  programs.steam.gamescopeSession = {
    args = ["--prefer-vk-device 1002:6606"];
    env = {
      DRI_PRIME = "1";
      AMD_VULKAN_ICD = "RADV";
      DISABLE_HDR_WSI = "1";
      MESA_VK_WSI_PRESENT_MODE = "fifo";
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";
      RADV_PERFTEST = "gpl";
    };
  };

  environment.systemPackages = with pkgs; [
    pciutils
  ];
}
