{ pkgs, ... }:
{
  # Свежее ядро под AMD Ryzen AI 9 HX 370 (Strix Point), Radeon 890M и MediaTek MT7925
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader.grub = {
      enable = true;
      useOSProber = true;
      configurationLimit = 10;
    };
  };

  services.fstrim.enable = true;

  # 32 ГБ ОЗУ: сжатый swap в памяти без гибернации на диск
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Совместимость системных часов в dual-boot с Windows 11:
  # в LOCAL-режиме systemd-timesyncd не пишет в RTC, а save-hwclock удалён из nixpkgs
  time.hardwareClockInLocalTime = true;

  systemd = {
    services.sync-rtc-localtime = {
      description = "Sync NTP-synchronized system clock to RTC in local time";
      after = [ "systemd-timesyncd.service" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig = {
        ConditionPathExists = [
          "/dev/rtc"
          "/run/systemd/timesync/synchronized"
        ];
        StartLimitIntervalSec = 0;
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.util-linux}/bin/hwclock --systohc --localtime --noadjfile";
      };
    };

    paths.sync-rtc-localtime = {
      description = "Watch NTP synchronization state to update local RTC";
      wantedBy = [ "multi-user.target" ];
      pathConfig.PathChanged = "/run/systemd/timesync/synchronized";
    };
  };
}
