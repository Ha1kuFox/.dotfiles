{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "translator" config.mods) {
    environment.systemPackages = with pkgs; [
      (tesseract.override {enableLanguages = ["eng" "chi_sim" "rus"];})
      python313Packages.argostranslate
    ];
  };
}
