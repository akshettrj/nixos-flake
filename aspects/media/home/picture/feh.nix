{ config, lib, ... }: {
    config =
        let
            biryani_media = config.biryani.programs.media;
            biryani_pics = config.biryani.programs.media.picture;
        in
        lib.mkIf (biryani_media.enable && biryani_pics.feh.enable) {
            programs.feh = {
                enable = true;
            };
        };
}
