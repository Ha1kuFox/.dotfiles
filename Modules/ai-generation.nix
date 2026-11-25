{
  config,
  lib,
  pkgs,
  ...
}: let
  comfyuiStart = pkgs.writeShellApplication {
    name = "comfyui-start";
    runtimeInputs = [pkgs.git pkgs.python313 pkgs.coreutils];
    text = ''
      AI_ROOT="$HOME/AI"
      export LD_LIBRARY_PATH="${lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib pkgs.zstd ]}"
      APP="$AI_ROOT/ComfyUI"
      VENV="$AI_ROOT/.venv"
      INSTALLED="$AI_ROOT/.comfyui-dependencies-installed"

      mkdir -p "$AI_ROOT"/models/{checkpoints,configs,loras,vae,vae_approx,embeddings,controlnet,t2i_adapter,clip,clip_vision,upscale_models,latent_upscale_models,hypernetworks,diffusion_models,unet,text_encoders,style_models,diffusers,gligen}
      mkdir -p "$AI_ROOT"/{workflows,datasets/characters,input,output,user}

      if [ ! -d "$APP/.git" ]; then
        if [ -e "$APP" ]; then
          echo "ComfyUI path exists but is not a Git repository: $APP" >&2
          exit 1
        fi
        git clone --depth 1 https://github.com/Comfy-Org/ComfyUI.git "$APP"
      fi

      if [ ! -x "$VENV/bin/python" ]; then
        ${pkgs.python313}/bin/python -m venv "$VENV"
      fi

      if [ ! -f "$INSTALLED" ]; then
        "$VENV/bin/python" -m pip install --upgrade pip
        "$VENV/bin/python" -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm7.2
        "$VENV/bin/python" -m pip install -r "$APP/requirements.txt"

        if [ -f "$APP/manager_requirements.txt" ]; then
          "$VENV/bin/python" -m pip install -r "$APP/manager_requirements.txt"
        fi

        touch "$INSTALLED"
      fi

      cat > "$AI_ROOT/extra_model_paths.yaml" <<'YAML'
      ai_generation:
        base_path: /home/user/AI
        checkpoints: models/checkpoints/
        configs: models/configs/
        loras: models/loras/
        vae: models/vae/
        text_encoders: |
          models/text_encoders/
          models/clip/
        diffusion_models: |
          models/unet/
          models/diffusion_models/
        clip_vision: models/clip_vision/
        style_models: models/style_models/
        embeddings: models/embeddings/
        diffusers: models/diffusers/
        vae_approx: models/vae_approx/
        controlnet: |
          models/controlnet/
          models/t2i_adapter/
        gligen: models/gligen/
        upscale_models: models/upscale_models/
        latent_upscale_models: models/latent_upscale_models/
        hypernetworks: models/hypernetworks/
        datasets: datasets/
      YAML

      exec "$VENV/bin/python" "$APP/main.py" \
        --listen 127.0.0.1 \
        --port 8188 \
        --enable-manager \
        --preview-method auto \
        --extra-model-paths-config "$AI_ROOT/extra_model_paths.yaml" \
        --input-directory "$AI_ROOT/input" \
        --output-directory "$AI_ROOT/output" \
        --user-directory "$AI_ROOT/user"
    '';
  };

  comfyuiUpdate = pkgs.writeShellApplication {
    name = "comfyui-update";
    runtimeInputs = [pkgs.git pkgs.coreutils];
    text = ''
      AI_ROOT="$HOME/AI"
      APP="$AI_ROOT/ComfyUI"
      VENV="$AI_ROOT/.venv"

      if [ ! -d "$APP/.git" ] || [ ! -x "$VENV/bin/python" ]; then
        echo "ComfyUI has not been initialized yet. Start the comfyui user service first." >&2
        exit 1
      fi

      git -C "$APP" pull --ff-only
      "$VENV/bin/python" -m pip install -r "$APP/requirements.txt"

      if [ -f "$APP/manager_requirements.txt" ]; then
        "$VENV/bin/python" -m pip install -r "$APP/manager_requirements.txt"
      fi

      echo "ComfyUI updated. Restart it with: systemctl --user restart comfyui"
    '';
  };

  comfyuiCheck = pkgs.writeShellApplication {
    name = "comfyui-check";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      PYTHON="$HOME/AI/.venv/bin/python"
      export LD_LIBRARY_PATH="${lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib pkgs.zstd ]}"
      if [ ! -x "$PYTHON" ]; then
        echo "ComfyUI environment is not initialized yet." >&2
        exit 1
      fi

      "$PYTHON" -c 'import torch; print("PyTorch:", torch.__version__); print("HIP:", torch.version.hip); print("GPU available:", torch.cuda.is_available()); print("Device:", torch.cuda.get_device_name(0) if torch.cuda.is_available() else "not detected")'
    '';
  };
in {
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
      "d /home/user/AI 0755 user users - -"
      "d /home/user/AI/models 0755 user users - -"
      "d /home/user/AI/models/checkpoints 0755 user users - -"
      "d /home/user/AI/models/configs 0755 user users - -"
      "d /home/user/AI/models/loras 0755 user users - -"
      "d /home/user/AI/models/vae 0755 user users - -"
      "d /home/user/AI/models/vae_approx 0755 user users - -"
      "d /home/user/AI/models/embeddings 0755 user users - -"
      "d /home/user/AI/models/controlnet 0755 user users - -"
      "d /home/user/AI/models/t2i_adapter 0755 user users - -"
      "d /home/user/AI/models/clip 0755 user users - -"
      "d /home/user/AI/models/clip_vision 0755 user users - -"
      "d /home/user/AI/models/upscale_models 0755 user users - -"
      "d /home/user/AI/models/latent_upscale_models 0755 user users - -"
      "d /home/user/AI/models/hypernetworks 0755 user users - -"
      "d /home/user/AI/models/diffusion_models 0755 user users - -"
      "d /home/user/AI/models/unet 0755 user users - -"
      "d /home/user/AI/models/diffusers 0755 user users - -"
      "d /home/user/AI/models/gligen 0755 user users - -"
      "d /home/user/AI/models/text_encoders 0755 user users - -"
      "d /home/user/AI/models/style_models 0755 user users - -"
      "d /home/user/AI/workflows 0755 user users - -"
      "d /home/user/AI/datasets 0755 user users - -"
      "d /home/user/AI/datasets/characters 0755 user users - -"
      "d /home/user/AI/input 0755 user users - -"
      "d /home/user/AI/output 0755 user users - -"
      "d /home/user/AI/user 0755 user users - -"
    ];

    environment.systemPackages = [
      comfyuiUpdate
      comfyuiCheck
    ];

    # The first start clones ComfyUI and builds its isolated Python environment.
    # Model files and generated images remain outside the Nix store.
    systemd.user.services.comfyui = {
      description = "ComfyUI local image generation server";
      wantedBy = ["default.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${comfyuiStart}/bin/comfyui-start";
        Restart = "on-failure";
        RestartSec = "15s";
        TimeoutStartSec = "infinity";
        Environment = ["PYTHONNOUSERSITE=1"];
      };
    };
  };
}
