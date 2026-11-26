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
  # Также патчим SpecialWorkspaces/Workspace/Hypr.qml: в Hyprland 0.57+ все special:* воркспейсы
  # возвращают id=null (0 в QML), из-за чего в панели все спецворкспейсы дублировали один и тот же
  # воркспейс и смешивали окна всех special:* воркспейсов.
  caelestiaShellFixed =
    (inputs.caelestia-shell.packages.${system}.with-cli.override {
      makeFontsConf = _: "/etc/fonts/fonts.conf";
    }).overrideAttrs
      (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace services/Hypr.qml \
            --replace-fail \
              'function toplevelsForWs(ws: int, ignoredTags = []): list<HyprlandToplevel> {
                  return toplevels.values.filter(t => t.workspace && t.workspace.id === ws && !isToplevelIgnored(t, ignoredTags));
              }' \
              'function toplevelsForWs(ws: int, ignoredTags = []): list<HyprlandToplevel> {
                  return toplevels.values.filter(t => t.workspace && t.workspace.id === ws && !isToplevelIgnored(t, ignoredTags));
              }

              function toplevelsForWsName(wsName: string, ignoredTags = []): list<HyprlandToplevel> {
                  return toplevels.values.filter(t => t.workspace && t.workspace.name === wsName && !isToplevelIgnored(t, ignoredTags));
              }'

          substituteInPlace modules/bar/components/workspaces/Workspace.qml \
            --replace-fail \
              'required property int modelData
              required property int index
              required property int activeWsId
              required property int ws' \
              'required property var modelData
              required property int index
              property int activeWsId: 0
              property int ws: 0
              property string wsName: ""
              property string activeWsName: ""' \
            --replace-fail \
              'readonly property list<HyprlandToplevel> toplevels: Hypr.toplevelsForWs(ws, GlobalConfig.bar.workspaces.ignoredTags)' \
              'readonly property list<HyprlandToplevel> toplevels: wsName ? Hypr.toplevelsForWsName(wsName, GlobalConfig.bar.workspaces.ignoredTags) : Hypr.toplevelsForWs(ws, GlobalConfig.bar.workspaces.ignoredTags)' \
            --replace-fail \
              'readonly property bool focused: activeWsId === ws' \
              'readonly property bool focused: wsName ? activeWsName === wsName : activeWsId === ws' \
            --replace-fail \
              'const mon = Hypr.workspaces.values.find(w => w.id === ws)?.monitor;' \
              'const mon = (wsName ? Hypr.workspaces.values.find(w => w.name === wsName) : Hypr.workspaces.values.find(w => w.id === ws))?.monitor;' \
            --replace-fail \
              'const ws = Hypr.workspaces.values.find(w => w.id === root.ws);' \
              'const ws = root.wsName ? Hypr.workspaces.values.find(w => w.name === root.wsName) : Hypr.workspaces.values.find(w => w.id === root.ws);' \
            --replace-fail \
              'readonly property HyprlandWorkspace wsObj: Hypr.workspaces.values.find(w => w.id === root.ws) ?? null' \
              'readonly property HyprlandWorkspace wsObj: (root.wsName ? Hypr.workspaces.values.find(w => w.name === root.wsName) : Hypr.workspaces.values.find(w => w.id === root.ws)) ?? null'

          substituteInPlace modules/bar/components/workspaces/SpecialWorkspaces.qml \
            --replace-fail \
              'readonly property int activeSpecialId: monitor?.lastIpcObject.specialWorkspace?.id ?? 0
              readonly property var wsIds: {
                  const allMonitors = !Config.bar.workspaces.perMonitor;
                  return Hypr.workspaces.values.filter(w => w.name.startsWith("special:") && (allMonitors || w.monitor === root.monitor)).map(w => w.id);
              }
              readonly property int activeIdx: wsIds.indexOf(activeSpecialId)' \
              'readonly property string activeSpecialName: monitor?.lastIpcObject.specialWorkspace?.name ?? ""
              readonly property var wsNames: {
                  const allMonitors = !Config.bar.workspaces.perMonitor;
                  return Hypr.workspaces.values.filter(w => w.name.startsWith("special:") && (allMonitors || w.monitor === root.monitor)).map(w => w.name);
              }
              readonly property int activeIdx: wsNames.indexOf(activeSpecialName)' \
            --replace-fail \
              'model: ScriptModel {
                      values: root.wsIds
                  }

                  delegate: Workspace {
                      activeWsId: root.activeSpecialId
                      ws: modelData' \
              'model: ScriptModel {
                      values: root.wsNames
                  }

                  delegate: Workspace {
                      activeWsName: root.activeSpecialName
                      wsName: modelData' \
            --replace-fail \
              'const ws = view.itemAt(event.x, event.y - view.y) as Workspace;
                      if (ws) {
                          const match = Hypr.workspaces.values.find(w => w.id === ws.ws);
                          if (match)
                              Hypr.toggleSpecial(Hypr.trimWsName(match.name));' \
              'const ws = view.itemAt(event.x, event.y - view.y) as Workspace;
                      if (ws && ws.wsName) {
                          Hypr.toggleSpecial(Hypr.trimWsName(ws.wsName));'
        '';
      });

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

    # Единый путь к обоям для systemd-сервиса caelestia-shell и caelestia-cli
    "environment.d/20-caelestia.conf".text = ''
      CAELESTIA_WALLPAPERS_DIR=${config.home.homeDirectory}/Изображения/Wallpapers
    '';
  };

  home.sessionVariables.CAELESTIA_WALLPAPERS_DIR = "${config.home.homeDirectory}/Изображения/Wallpapers";

  # Однократный seed перезаписываемых конфигов (btop и Thunar) и рабочих директорий
  home.activation.seedCaelestiaMutableConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p \
      "$HOME/.config/btop/themes" \
      "$HOME/.config/Thunar" \
      "$HOME/.config/hypr/scheme" \
      "$HOME/.local/state/caelestia" \
      "$HOME/.local/share/fonts" \
      "$HOME/Изображения/Wallpapers"

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
