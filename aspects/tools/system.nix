{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.programs.extra_utilities = {
        drivedlgo.enable = lib.mkEnableOption "drivedlgo utility package";
        librepods.enable = lib.mkEnableOption "librepods utility package";
        ffmpeg.enable = lib.mkEnableOption "FFmpeg and thumbnailer utilities";
        obs.enable = lib.mkEnableOption "OBS Studio";
        odesli.enable = lib.mkEnableOption "odesli-rs utility package";
        pleezer.enable = lib.mkEnableOption "Pleezer utility package";
        rclone.enable = lib.mkEnableOption "rclone utility package";
        taggie.enable = lib.mkEnableOption "taggie utility package";
        typst.enable = lib.mkEnableOption "Typst and Tinymist tooling";
        ueberzugpp.enable = lib.mkEnableOption "ueberzugpp terminal image support";
        yt-dlp.enable = lib.mkEnableOption "yt-dlp media downloader";
        gh.enable = lib.mkEnableOption "GitHub CLI";
        obsidian.enable = lib.mkEnableOption "Obsidian and obsidian-export";
    };

    config =
        let
            biryani_extra_utils = config.biryani.programs.extra_utilities;
        in
        {
            environment.systemPackages =
                [ ]
                ++ lib.optionals biryani_extra_utils.drivedlgo.enable [
                    inputs.nixur.legacyPackages."${pkgs.stdenv.hostPlatform.system}".drivedlgo
                ]
                ++ lib.optionals biryani_extra_utils.ffmpeg.enable [
                    pkgs.ffmpeg
                    pkgs.ffmpegthumbnailer
                ]
                ++ lib.optionals biryani_extra_utils.obs.enable [ pkgs.obs-studio ]
                ++ lib.optionals biryani_extra_utils.odesli.enable [
                    inputs.odesli.packages."${pkgs.stdenv.hostPlatform.system}".default
                ]
                ++ lib.optionals biryani_extra_utils.pleezer.enable [
                    inputs.nixur.legacyPackages."${pkgs.stdenv.hostPlatform.system}".pleezer
                ]
                ++ lib.optionals biryani_extra_utils.rclone.enable [ pkgs.rclone ]
                ++ lib.optionals biryani_extra_utils.taggie.enable [
                    inputs.nixur.legacyPackages."${pkgs.stdenv.hostPlatform.system}".taggie
                ]
                ++ lib.optionals biryani_extra_utils.typst.enable [
                    pkgs.typst
                    pkgs.tinymist
                ]
                ++ lib.optionals biryani_extra_utils.ueberzugpp.enable [ pkgs.ueberzugpp ]
                ++ lib.optionals biryani_extra_utils.gh.enable [ pkgs.gh ]
                ++ lib.optionals biryani_extra_utils.yt-dlp.enable [ pkgs.yt-dlp ]
                ++ lib.optionals biryani_extra_utils.obsidian.enable [
                    pkgs.obsidian
                    pkgs.obsidian-export
                ]
                ++ lib.optionals biryani_extra_utils.librepods.enable [
                    inputs.nixur.legacyPackages."${pkgs.stdenv.hostPlatform.system}".librepods
                ];
        };
}
