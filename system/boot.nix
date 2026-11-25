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

  # Совместимость системных часов в dual-boot с Windows 11
  time.hardwareClockInLocalTime = true;
}
