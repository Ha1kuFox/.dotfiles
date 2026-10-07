{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        # Nix
        jnoortheen.nix-ide
        arrterian.nix-env-selector
      ];
    })
  ];
}
