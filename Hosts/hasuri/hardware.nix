{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" "sdhci_pci"];
    kernelModules = ["amdgpu"];
    initrd.kernelModules = ["amdgpu"];
    extraModprobeConfig = "
        options amdgpu runpm=0
      ";
  };
  boot.extraModulePackages = [];

  services.xserver.videoDrivers = ["amdgpu"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a1672c80-f8f7-456f-8ac6-0062208627c6";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/23C2-3FF1";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/0efd7339-3c6e-4b9f-b288-076da3a89df3";}
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
