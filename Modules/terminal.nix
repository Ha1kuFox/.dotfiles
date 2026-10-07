{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (lib.elem "terminal" config.mods) {
    environment.systemPackages = with pkgs; [
      kitty
      # CLI
      just
      git
      eza
      yazi

      # Nix
      nixd
      alejandra
    ];

    users.extraUsers.user.shell = pkgs.fish;
    programs = {
      fish = {
        enable = true;
        shellAbbrs = {
          ls = "eza --icons";
        };
        interactiveShellInit = ''
          set fish_greeting
          if test -f ~/.cache/terminal-sequences
              cat ~/.cache/terminal-sequences &
          end
        '';
      };
      direnv = {
        enable = true;
        enableFishIntegration = true;
      };
      zoxide = {
        enable = true;
        enableFishIntegration = true;
      };
      starship = {
        enable = true;
      };
    };
  };
}
