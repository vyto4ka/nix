{
  config,
  lib,
  pkgs,
  inputs,
  configDir,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (config.lib.file) mkOutOfStoreSymlink;

  # Подменяем изолированный makeFontsConf (из 3 шрифтов) на системный /etc/fonts/fonts.conf,
  # чтобы makeWrapper/makeCWrapper нативно вшил FONTCONFIG_FILE=/etc/fonts/fonts.conf и все
  # приложения из лаунчера Caelestia (fork/exec) видели системные, пользовательские и эмодзи-шрифты.
  caelestiaShellFixed = inputs.caelestia-shell.packages.${system}.with-cli.override {
    makeFontsConf = _: "/etc/fonts/fonts.conf";
  };

  # Адаптация апстримных дотсов Caelestia под NixOS без поддержки отдельного форка:
  # убираем дублирующий старт шелла (им управляет systemd caelestia.service) и пути Arch Linux.
  caelestiaDotsNixos = pkgs.runCommand "caelestia-dots-nixos" { } ''
    cp -r ${inputs.caelestia-dots} "$out"
    chmod -R u+w "$out"
    sed -i \
      -e '/caelestia shell -d/d' \
      -e '\|/usr/lib/polkit-gnome/|d' \
      -e '\|/usr/lib/geoclue-2.0/|d' \
      "$out/hypr/hyprland/execs.lua"
  '';

  # Пофайловая раскладка hypr/* (исключая динамическую папку scheme/, куда пишется current.lua)
  collectRelativeFiles =
    dir: prefix:
    lib.concatMapAttrs (
      name: kind:
      let
        rel = if prefix == "" then name else "${prefix}/${name}";
      in
      if rel == "scheme" then
        { }
      else if kind == "directory" then
        collectRelativeFiles (dir + "/${name}") rel
      else
        {
          "hypr/${rel}".source = "${caelestiaDotsNixos}/hypr/${rel}";
        }
    ) (builtins.readDir dir);

  hyprConfigEntries = collectRelativeFiles (inputs.caelestia-dots + "/hypr") "";
in
{
  programs.caelestia = {
    enable = true;
    package = caelestiaShellFixed;
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };
    cli.enable = true;
  };

  xdg.configFile = hyprConfigEntries // {
    # В ~/.config/hypr/scheme/ кладём только default.lua; каталог остаётся записываемым для current.lua
    "hypr/scheme/default.lua".source = "${caelestiaDotsNixos}/hypr/scheme/default.lua";

    # Конфиги окружения Caelestia
    "uwsm" = {
      source = "${caelestiaDotsNixos}/uwsm";
      recursive = true;
    };
    "foot/foot.ini".source = "${caelestiaDotsNixos}/foot/foot.ini";
    "fastfetch/config.jsonc".source = "${caelestiaDotsNixos}/fastfetch/config.jsonc";
    "starship.toml".source = "${caelestiaDotsNixos}/starship.toml";
    "fish/config.fish".source = "${caelestiaDotsNixos}/fish/config.fish";
    "fish/functions" = {
      source = "${caelestiaDotsNixos}/fish/functions";
      recursive = true;
    };
    "micro/settings.json".source = "${caelestiaDotsNixos}/micro/settings.json";

    # Ручные координаты Москвы для ночного режима gammastep (без geoclue)
    "gammastep/config.ini".text = ''
      [general]
      temp-day=6500
      temp-night=4200
      fade=1
      location-provider=manual
      adjustment-method=wayland

      [manual]
      lat=55.75
      lon=37.62
    '';

    # Живые переопределения из ~/nixos-config/home/caelestia/
    "caelestia/hypr-vars.lua".source = mkOutOfStoreSymlink "${configDir}/home/caelestia/hypr-vars.lua";
    "caelestia/hypr-user.lua".source = mkOutOfStoreSymlink "${configDir}/home/caelestia/hypr-user.lua";
    "caelestia/user-config.fish".source =
      mkOutOfStoreSymlink "${configDir}/home/caelestia/user-config.fish";
  };

  # Однократный seed перезаписываемых конфигов (btop и Thunar) и рабочих директорий
  home.activation.seedCaelestiaMutableConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p \
      "$HOME/.config/btop/themes" \
      "$HOME/.config/Thunar" \
      "$HOME/.config/hypr/scheme" \
      "$HOME/.local/state/caelestia/theme" \
      "$HOME/.local/share/fonts"

    if [ ! -e "$HOME/.local/state/caelestia/theme/chrome.json" ]; then
      printf '%s\n' '{"BrowserThemeColor":"#141318","BrowserColorScheme":"device"}' \
        > "$HOME/.local/state/caelestia/theme/chrome.json"
    fi

    if [ ! -e "$HOME/.config/btop/btop.conf" ]; then
      install -m 0644 "${caelestiaDotsNixos}/btop/btop.conf" "$HOME/.config/btop/btop.conf"
    fi

    for f in "${caelestiaDotsNixos}/thunar/"*; do
      [ -e "$f" ] || continue
      base="$(basename "$f")"
      if [ ! -e "$HOME/.config/Thunar/$base" ]; then
        install -m 0644 "$f" "$HOME/.config/Thunar/$base"
      fi
    done
  '';
}
