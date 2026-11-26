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
    # Отключаем Panel Replay на OLED DCN 3.5 (ASUS Zenbook UM5606 / Strix Point)
    "amdgpu.dcdebugmask=0x400"
  ];
}
