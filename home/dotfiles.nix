{
  config,
  lib,
  configDir,
  ...
}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;

  # Папка в репозитории, структура которой зеркалируется в ~/.config/
  dotfilesDir = ../config;
  dotfilesPath = "${configDir}/config";

  ignoredNames = [
    ".gitkeep"
    ".DS_Store"
  ];

  # Рекурсивная пофайловая раскладка: каталоги в ~/.config/ остаются записываемыми,
  # а живые симлинки создаются только на конкретные файлы (mkOutOfStoreSymlink
  # несовместим с recursive = true в Home Manager).
  collectRelativeFiles =
    dir: prefix:
    lib.concatMapAttrs (
      name: kind:
      let
        rel = if prefix == "" then name else "${prefix}/${name}";
      in
      if builtins.elem name ignoredNames then
        { }
      else if kind == "directory" then
        collectRelativeFiles (dir + "/${name}") rel
      else if kind == "regular" || kind == "symlink" then
        {
          ${rel} = {
            source = lib.mkOverride 90 (mkOutOfStoreSymlink "${dotfilesPath}/${rel}");
            force = lib.mkOverride 90 true;
          };
        }
      else
        { }
    ) (builtins.readDir dir);
in
{
  xdg.configFile = lib.optionalAttrs (builtins.pathExists dotfilesDir) (
    collectRelativeFiles dotfilesDir ""
  );
}
