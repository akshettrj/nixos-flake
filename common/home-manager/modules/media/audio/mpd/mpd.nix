{
  config,
  lib,
  pkgs,
  pkgs_stable,
  ...
}: {
  config = let
    pro_media = config.propheci.programs.media;
    pro_mpd = config.propheci.programs.media.audio.mpd;
  in
    lib.mkIf (pro_media.enable && pro_mpd.enable) {
      services.mpd = {
        enable = true;
        extraConfig = ''
          auto_update "yes"
          restore_paused "yes"

          audio_output {
              type "pulse"
              name "Music"
          }

          audio_output {
              type "fifo"
              name "ncmpcpp visualizer"
              path "/tmp/mpd.fifo"
              format "44100:16:2"
          }
        '';
      };

      home.packages = [pkgs.mpc];
    };
}
