{
  hardware = {
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true;
    amdgpu.initrd.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  boot.kernelParams = [
    # Резерв при фризах OLED или выхода из сна на RDNA 3.5 (отключает PSR):
    # "amdgpu.dcdebugmask=0x400"
  ];
}
