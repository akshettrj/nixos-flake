{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.programs.social_media = {
        telegram.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Install Telegram Desktop through Home Manager.";
        };

        discord.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Install Discord through Home Manager.";
        };

        beeper.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Install Beeper through Home Manager.";
        };

        slack.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Install Slack through Home Manager.";
        };

        teams.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Install Teams for Linux through Home Manager.";
        };

        zulip.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Install Zulip desktop and terminal clients through Home Manager.";
        };
    };

    config =
        let
            biryani_social_media = config.biryani.programs.social_media;
        in
        {
            home.packages =
                lib.optionals biryani_social_media.telegram.enable [ pkgs.telegram-desktop ]
                ++ lib.optionals biryani_social_media.discord.enable [ pkgs.discord ]
                ++ lib.optionals biryani_social_media.beeper.enable [ pkgs.beeper ]
                ++ lib.optionals biryani_social_media.slack.enable [ pkgs.slack ]
                ++ lib.optionals biryani_social_media.teams.enable [ pkgs.teams-for-linux ]
                ++ lib.optionals biryani_social_media.zulip.enable [
                    pkgs.zulip
                    pkgs.zulip-term
                ];
        };
}
