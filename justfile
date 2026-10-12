default:
    just --help

switch:
    sudo nixos-rebuild switch --flake . --diff

clean:
    sudo nix-collect-garbage -d

format:
    find . -name "*.qml" -exec qmlformat -i {} \;
    alejandra .

check:
    nix flake check --no-build
