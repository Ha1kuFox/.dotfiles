{
  imports = [
    ./hardware.nix
    ./modules.nix
  ];

  environment.sessionVariables = {
    AMD_VULKAN_ICD = "RADV";
    DISABLE_HDR_WSI = "1";
    MESA_VK_WSI_PRESENT_MODE = "fifo";
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    RADV_PERFTEST = "gpl";
  };
}
