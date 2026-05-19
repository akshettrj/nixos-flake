{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_media = config.biryani.programs.media;
            biryani_video = config.biryani.programs.media.video;
        in
        lib.mkIf (biryani_media.enable && biryani_video.jellyfin.enable) {
            home.packages = [
                pkgs.jellyfin-media-player
            ]
            ++ lib.optionals biryani_video.mpv.enable [ pkgs.jellyfin-mpv-shim ];
        };
}
