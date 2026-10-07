{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    concat = {
      url = "github:jub0t/concat";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs.legacyPackages.${system};
    lib = inputs.nixpkgs.lib;
    hostNames = builtins.attrNames (
      lib.filterAttrs (_: t: t == "directory") (builtins.readDir ./Hosts)
    );
  in {
    packages.${system} = {
      cspenguin-wine = pkgs.callPackage ./Packages/cspenguin/wine.nix {};
      concat = inputs.concat.packages.${system}.default;
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nixd
        alejandra
        statix
        deadnix
      ];
    };

    # Новый хост = новая папка в Hosts/, hostname берётся из имени папки.
    # Модули хоста выбираются через `mods = [ ... ]` в Hosts/<имя>/modules.nix.
    nixosConfigurations = lib.genAttrs hostNames (host:
      lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          (./Hosts + "/${host}")
          ./Modules
          {networking.hostName = lib.mkDefault host;}
        ];
      });
  };
}
