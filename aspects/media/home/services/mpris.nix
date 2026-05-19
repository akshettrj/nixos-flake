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
        in
        lib.mkIf (biryani_media.enable && biryani_media.services.mpris.enable) {
            home.packages = [ pkgs.playerctl ];
        };
}
