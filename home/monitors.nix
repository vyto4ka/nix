{ lib, pkgs, ... }:
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
      ExecStart = "${pkgs.hyprdynamicmonitors}/bin/hyprdynamicmonitors run --config %h/.config/hyprdynamicmonitors/config.toml --enable-lid-events --disable-power-events";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Конфиги hyprdynamicmonitors подключаются живыми симлинками из config/hyprdynamicmonitors/
  # через home/dotfiles.nix; здесь гарантируем существование ~/.config/hypr для monitors.conf
  home.activation.ensureHyprDynamicMonitorsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/hypr"
  '';
}
