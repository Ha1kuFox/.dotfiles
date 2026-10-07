{inputs, pkgs, ...}: {
  # Concat — free open-source video editor (CapCut replacement).
  # Built from the upstream flake (github:jub0t/concat), wired in as the
  # `concat` flake input, so no local packaging to maintain.
  environment.systemPackages = [
    inputs.concat.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
