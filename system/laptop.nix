{ pkgs, ... }:
{
  services = {
    asusd.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
    fwupd.enable = true;

    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };
  };

  # Применение лимита заряда батареи 80% через живой демон asusd
  systemd.services.asusd-charge-limit = {
    description = "Set ASUS battery charge limit to 80%";
    after = [ "asusd.service" ];
    wants = [ "asusd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "-${pkgs.asusctl}/bin/asusctl -c 80";
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      Experimental = true;
      FastConnectable = true;
    };
  };

  services.blueman.enable = true;
}
