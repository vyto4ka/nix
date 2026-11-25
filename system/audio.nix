{ pkgs, ... }:
{
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    wireplumber.enable = true;

    # RNNoise LADSPA в LADSPA_PATH (PipeWire 1.6+ требует плагины из пути поиска)
    extraLadspaPackages = [ pkgs.rnnoise-plugin.ladspa ];

    # Виртуальный микрофон с нейросетевым шумодавом RNNoise (срезает фоновый шум DMIC)
    extraConfig.pipewire."99-input-denoising" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "Noise Canceling Microphone";
            "media.name" = "Noise Canceling Microphone";
            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "rnnoise";
                  plugin = "librnnoise_ladspa";
                  label = "noise_suppressor_mono";
                  control = {
                    "VAD Threshold (%)" = 50.0;
                    "VAD Grace Period (ms)" = 200;
                    "Retroactive VAD Grace (ms)" = 0;
                  };
                }
              ];
            };
            "capture.props" = {
              "node.name" = "capture.rnnoise_source";
              "node.passive" = true;
              "audio.rate" = 48000;
              "audio.position" = [ "MONO" ];
            };
            "playback.props" = {
              "node.name" = "rnnoise_source";
              "media.class" = "Audio/Source";
              "audio.rate" = 48000;
              "audio.position" = [ "MONO" ];
            };
          };
        }
      ];
    };
  };
}
