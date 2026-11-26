{ pkgs, inputs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;

  # Принудительно запускаем Vesktop в нативном Wayland с PipeWire-захватом экрана
  vesktopWayland = pkgs.symlinkJoin {
    name = "vesktop-wayland";
    paths = [ pkgs.vesktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/vesktop" \
        --set XDG_SESSION_TYPE wayland \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer"
    '';
  };
in
{
  home.packages = with pkgs; [
    vscodium
    antigravity-hub
    antigravity-ide
    antigravity-cli
    inputs.vysh.packages.${system}.default
    bitwarden-desktop
    obsidian
    ayugram-desktop
    vesktopWayland
    vlc
    bat
    duf
    kdePackages.ark
    kdePackages.gwenview
  ];
}
