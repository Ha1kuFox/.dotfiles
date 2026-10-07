{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (tesseract.override {enableLanguages = ["eng" "chi_sim" "rus"];})
    python313Packages.argostranslate
  ];
}
