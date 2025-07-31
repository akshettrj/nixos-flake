{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_extra_utils = config.propheci.programs.extra_utilities;
  in {
    environment.systemPackages =
      []
      ++ lib.optionals pro_extra_utils.drivedlgo.enable [
        inputs.nixur.legacyPackages."${pkgs.system}".drivedlgo
      ]
      ++ lib.optionals pro_extra_utils.ffmpeg.enable [
        pkgs.ffmpeg
        pkgs.ffmpegthumbnailer
      ]
      ++ lib.optionals pro_extra_utils.obs.enable [
        pkgs.obs-studio
      ]
      ++ lib.optionals pro_extra_utils.odesli.enable [
        inputs.odesli.packages."${pkgs.system}".default
      ]
      ++ lib.optionals pro_extra_utils.pleezer.enable [
        inputs.nixur.legacyPackages."${pkgs.system}".pleezer
      ]
      ++ lib.optionals pro_extra_utils.rclone.enable [
        pkgs.rclone
      ]
      ++ lib.optionals pro_extra_utils.taggie.enable [
        inputs.nixur.legacyPackages."${pkgs.system}".taggie
      ]
      ++ lib.optionals pro_extra_utils.typst.enable [
        pkgs.typst
        pkgs.tinymist
      ]
      ++ lib.optionals pro_extra_utils.ueberzugpp.enable [
        pkgs.ueberzugpp
      ]
      ++ lib.optionals pro_extra_utils.yt-dlp.enable [
        pkgs.yt-dlp
      ];
  };
}
