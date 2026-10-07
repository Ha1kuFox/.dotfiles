{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    direnv-nvim = {
      url = "github:NotAShelf/direnv.nvim";
      flake = false;
    };
    cendre.url = "github:Aejkatappaja/cendre";
    cendre.flake = false;
    lsp-lens-nvim.url = "github:VidocqH/lsp-lens.nvim";
    lsp-lens-nvim.flake = false;
  };

  outputs = inputs: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = fn:
      inputs.nixpkgs.lib.genAttrs supportedSystems (system:
        fn inputs.nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (pkgs: {
      cspenguin-wine = pkgs.callPackage ./Packages/cspenguin/wine.nix {};
    });

    nixosConfigurations = {
      hasuri = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./Hosts/hasuri
          ./Modules/cosmic.nix
          ./Modules/system.nix
          ./Modules/v2raya.nix
          ./Modules/neovim.nix
          ./Modules/terminal.nix
          ./Modules/gaming.nix
          ./Modules/firefox.nix
          ./Modules/shell.nix
          ./Modules/sync.nix
          ./Modules/bluetooth.nix
          ./Modules/screenshot.nix
          ./Modules/recorder.nix
        ];
      };
      haikyo = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./Hosts/haikyo
          ./Modules/cspenguin.nix
          ./Modules/hypr.nix
          ./Modules/system.nix
	  ./Modules/vscode.nix
          ./Modules/terminal.nix
          ./Modules/gaming.nix
          ./Modules/firefox.nix
          ./Modules/shell.nix
          ./Modules/recorder.nix
          ./Modules/godot.nix
          ./Modules/screenshot.nix
        ];
      };
      setsu = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./Hosts/setsu
          ./Modules/system.nix
          ./Modules/neovim.nix
          ./Modules/cosmic.nix
          ./Modules/terminal.nix
          ./Modules/gaming.nix
          ./Modules/firefox.nix
          ./Modules/shell.nix
          ./Modules/recorder.nix
          ./Modules/sync.nix
          ./Modules/screenshot.nix
          ./Modules/bluetooth.nix
        ];
      };
    };
  };
}
