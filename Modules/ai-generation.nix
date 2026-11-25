{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "ai-generation" config.mods) {
    # ROCm / HIP runtime for local ML workloads (e.g. PyTorch and ComfyUI).
    hardware.amdgpu.opencl.enable = true;
    hardware.graphics.extraPackages = [
      pkgs.rocmPackages.clr.icd
    ];
    nixpkgs.config.rocmSupport = true;

    # Allow the interactive user to access ROCm device nodes.
    users.users.user.extraGroups = ["video"];

    # ROCm applications commonly expect HIP at /opt/rocm/hip.
    systemd.tmpfiles.rules = [
      "d /opt/rocm - - - - -"
      "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
    ];
  };
}
