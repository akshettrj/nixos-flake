{ lib, config, ... }:
{
    options.biryani.programs.screenlocks = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Home Manager screen lock configuration.";
        };

        swaylock.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Swaylock through Home Manager.";
        };
    };

    config =
        let
            biryani_screenlocks = config.biryani.programs.screenlocks;
            biryani_theming = config.biryani.theming;
        in
        lib.mkIf (biryani_screenlocks.enable && biryani_screenlocks.swaylock.enable) {
            programs.swaylock = {
                enable = true;
                settings = {
                    show-failed-attempts = true;
                    ignore-empty-password = true;

                    color = "000000";
                    font = biryani_theming.fonts.main.name;
                    inside-color = "1F202A";
                    line-color = "1F202A";
                    ring-color = "bd93f9";
                    text-color = "f8f8f2";
                    layout-bg-color = "000000";
                    layout-text-color = "f8f8f2";
                    inside-clear-color = "6272a4";
                    line-clear-color = "1F202A";
                    ring-clear-color = "6272a4";
                    text-clear-color = "1F202A";
                    inside-ver-color = "bd93f9";
                    line-ver-color = "1F202A";
                    ring-ver-color = "bd93f9";
                    text-ver-color = "1F202A";
                    inside-wrong-color = "ff5555";
                    line-wrong-color = "1F202A";
                    ring-wrong-color = "ff5555";
                    text-wrong-color = "1F202A";
                    bs-hl-color = "ff5555";
                    key-hl-color = "50fa7b";
                    text-caps-lock-color = "f8f8f2";
                };
            };
        };
}
