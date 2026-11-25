{ pkgs, ... }:
{
  # Набор системных библиотек для сторонних ELF-бинарников (без хостового Qt во избежание ABI-конфликтов)
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld;
    libraries = with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      curl
      dbus
      expat
      fontconfig
      freetype
      fuse3
      gdk-pixbuf
      glib
      gtk3
      icu
      libdrm
      libgbm
      libglvnd
      libnotify
      libpulseaudio
      libsecret
      libuuid
      libva
      libxkbcommon
      mesa
      nspr
      nss
      openssl
      pango
      pipewire
      stdenv.cc.cc
      systemd
      vulkan-loader
      wayland
      libx11
      libxscrnsaver
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxtst
      libxcb
      libxshmfence
      zlib
      zstd
    ];
  };
}
