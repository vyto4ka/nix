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
  # Временный обход падения JSC::intlAvailableTimeZoneEntries в WebKitGTK 2.54.2 + ICU 78
  webkitPkgs = inputs.nixpkgs-webkit.legacyPackages.${system};
  ayugramFixed = pkgs.ayugram-desktop.override {
    webkitgtk_4_1 = webkitPkgs.webkitgtk_4_1;
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
    ayugramFixed
    vesktopWayland
    vlc
    qimgv
    bat
    duf
    kdePackages.ark
    kdePackages.gwenview
  ];
}
