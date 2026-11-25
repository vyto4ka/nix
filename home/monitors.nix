{ lib, pkgs, ... }:
let
  defaultConfigToml = pkgs.writeText "hyprdynamicmonitors-config.toml" ''
    [general]
    destination = "$HOME/.config/hypr/monitors.conf"
    debounce_time_ms = 1200
    post_apply_exec = "hyprctl reload"

    [scoring]
    description_match = 15
    name_match = 10
    power_state_match = 3
    lid_state_match = 5

    # 1. Мобильный режим (крышка открыта, только встроенный OLED 2880x1800)
    [profiles.mobile]
    config_file = "hyprconfigs/mobile.go.tmpl"
    config_file_type = "template"

    [[profiles.mobile.conditions.required_monitors]]
    name = "eDP-1"
    monitor_tag = "laptop"

    # 2. Открытая крышка + внешний монитор(ы)
    [profiles.docked_open]
    config_file = "hyprconfigs/docked_open.go.tmpl"
    config_file_type = "template"

    [profiles.docked_open.conditions]
    lid_state = "Opened"

    [[profiles.docked_open.conditions.required_monitors]]
    name = "eDP-1"
    monitor_tag = "laptop"

    [[profiles.docked_open.conditions.required_monitors]]
    name = "^(DP|HDMI-A)-[0-9]+$"
    match_name_using_regex = true
    monitor_tag = "ext1"

    # 3. Clamshell: закрытая крышка + 1 внешний монитор
    [profiles.clamshell_single]
    config_file = "hyprconfigs/clamshell_single.go.tmpl"
    config_file_type = "template"

    [profiles.clamshell_single.conditions]
    lid_state = "Closed"

    [[profiles.clamshell_single.conditions.required_monitors]]
    name = "eDP-1"
    monitor_tag = "laptop"

    [[profiles.clamshell_single.conditions.required_monitors]]
    name = "^(DP|HDMI-A)-[0-9]+$"
    match_name_using_regex = true
    monitor_tag = "ext1"

    # 4. Clamshell: закрытая крышка + 2 внешних монитора по USB-C хабу
    # Для жёсткой привязки левого/правого мониторов по EDID (независимо от плавающих DP-*)
    # запустите `hyprdynamicmonitors tui --enable-lid-events` или замените regex name на description.
    [profiles.clamshell_dual]
    config_file = "hyprconfigs/clamshell_dual.go.tmpl"
    config_file_type = "template"

    [profiles.clamshell_dual.conditions]
    lid_state = "Closed"

    [[profiles.clamshell_dual.conditions.required_monitors]]
    name = "eDP-1"
    monitor_tag = "laptop"

    [[profiles.clamshell_dual.conditions.required_monitors]]
    name = "^(DP|HDMI-A)-[0-9]+$"
    match_name_using_regex = true
    monitor_tag = "ext1"

    [[profiles.clamshell_dual.conditions.required_monitors]]
    name = "^(DP|HDMI-A)-[0-9]+$"
    match_name_using_regex = true
    monitor_tag = "ext2"
  '';

  mobileTmpl = pkgs.writeText "mobile.go.tmpl" ''
    {{- $laptop := index .MonitorsByTag "laptop" -}}
    monitor={{$laptop.Name}},highrr,0x0,1.5
  '';

  dockedOpenTmpl = pkgs.writeText "docked_open.go.tmpl" ''
    {{- $laptop := index .MonitorsByTag "laptop" -}}
    {{- $ext1 := index .MonitorsByTag "ext1" -}}
    monitor={{$laptop.Name}},highrr,0x0,1.5
    monitor={{$ext1.Name}},preferred,auto,1
    {{- range .ExtraMonitors}}
    monitor={{.Name}},preferred,auto,1
    {{- end}}
  '';

  clamshellSingleTmpl = pkgs.writeText "clamshell_single.go.tmpl" ''
    {{- $laptop := index .MonitorsByTag "laptop" -}}
    {{- $ext1 := index .MonitorsByTag "ext1" -}}
    monitor={{$laptop.Name}},disable
    monitor={{$ext1.Name}},preferred,0x0,1
  '';

  clamshellDualTmpl = pkgs.writeText "clamshell_dual.go.tmpl" ''
    {{- $laptop := index .MonitorsByTag "laptop" -}}
    {{- $ext1 := index .MonitorsByTag "ext1" -}}
    {{- $ext2 := index .MonitorsByTag "ext2" -}}
    monitor={{$laptop.Name}},disable
    monitor={{$ext1.Name}},preferred,0x0,1
    monitor={{$ext2.Name}},preferred,auto,1
  '';
in
{
  home.packages = [
    pkgs.hyprdynamicmonitors
  ];

  # Очистка строк monitor=...,disable перед стартом графической сессии,
  # чтобы холодный старт без дока никогда не оставлял ноутбук с погашенным экраном
  systemd.user.services.hyprdynamicmonitors-prepare = {
    Unit = {
      Description = "HyprDynamicMonitors boot-time cleanup";
      Before = [ "graphical-session-pre.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.hyprdynamicmonitors}/bin/hyprdynamicmonitors prepare --config %h/.config/hyprdynamicmonitors/config.toml";
      TimeoutStartSec = 3;
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [
        "default.target"
        "graphical-session-pre.target"
      ];
    };
  };

  systemd.user.services.hyprdynamicmonitors = {
    Unit = {
      Description = "HyprDynamicMonitors dynamic monitor daemon";
      After = [
        "graphical-session.target"
        "hyprdynamicmonitors-prepare.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [
        "PATH=${
          lib.makeBinPath [
            pkgs.hyprland
            pkgs.upower
            pkgs.coreutils
          ]
        }:/run/current-system/sw/bin"
      ];
      ExecStart = "${pkgs.hyprdynamicmonitors}/bin/hyprdynamicmonitors run --config %h/.config/hyprdynamicmonitors/config.toml --enable-lid-events";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Seed записываемых конфигов, чтобы `hyprdynamicmonitors tui --enable-lid-events`
  # и `hyprdynamicmonitors freeze` могли сохранять офисные мониторы по EDID
  home.activation.seedHyprDynamicMonitors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/hyprdynamicmonitors/hyprconfigs" "$HOME/.config/hypr"

    if [ ! -e "$HOME/.config/hyprdynamicmonitors/config.toml" ]; then
      install -m 0644 "${defaultConfigToml}" "$HOME/.config/hyprdynamicmonitors/config.toml"
    fi

    for pair in \
      "mobile.go.tmpl:${mobileTmpl}" \
      "docked_open.go.tmpl:${dockedOpenTmpl}" \
      "clamshell_single.go.tmpl:${clamshellSingleTmpl}" \
      "clamshell_dual.go.tmpl:${clamshellDualTmpl}"; do
      name="''${pair%%:*}"
      src="''${pair#*:}"
      if [ ! -e "$HOME/.config/hyprdynamicmonitors/hyprconfigs/$name" ]; then
        install -m 0644 "$src" "$HOME/.config/hyprdynamicmonitors/hyprconfigs/$name"
      fi
    done
  '';
}
