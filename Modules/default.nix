# Авто-импорт всех модулей по имени файла
# Файлы начинающиеся на "_" пропускаются
{lib, ...}: let
  thisDir = ./.;
  files = lib.filterAttrs (
    n: t: t == "regular" && lib.hasSuffix ".nix" n && n != "default.nix" && !(lib.hasPrefix "_" n)
  ) (builtins.readDir thisDir);
  fileNames = builtins.attrNames files;
  modNames = map (lib.removeSuffix ".nix") fileNames;
in {
  imports = map (f: thisDir + "/${f}") fileNames;

  options.mods = lib.mkOption {
    type = lib.types.listOf (lib.types.enum modNames);
    default = [];
    description = "Кастомные модули для данного хоста";
    example = ''mods = [ "system" "hypr" ];'';
  };
}
