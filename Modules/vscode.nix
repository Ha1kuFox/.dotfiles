{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "vscode" config.mods) {
    environment.systemPackages = with pkgs; [
      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with vscode-extensions; [
          # Nix
          jnoortheen.nix-ide
          arrterian.nix-env-selector

          # Rust
          rust-lang.rust-analyzer
        ];
      })
    ];
  };
}
