{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.programs.notification_daemons = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Home Manager notification daemon support.";
        };

        dunst = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable Dunst as the Home Manager notification daemon.";
            };

            font_size = lib.mkOption {
                type = lib.types.ints.unsigned;
                description = "Font size used by Dunst notifications.";
            };
        };

        swaync = {
            enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Enable SwayNotificationCenter as the Home Manager notification daemon.";
            };
        };
    };

    config =
        let
            biryani_notifiers = config.biryani.programs.notification_daemons;
        in
        lib.mkIf biryani_notifiers.enable { home.packages = [ pkgs.libnotify ]; };
}
