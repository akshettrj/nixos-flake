{ lib, config, ... }: {
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
            palette =
                if biryani_theming.matugen.integrations.swaylock.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;
            noHash = lib.removePrefix "#";
        in
        lib.mkIf (biryani_screenlocks.enable && biryani_screenlocks.swaylock.enable) {
            programs.swaylock = {
                enable = true;
                settings = {
                    show-failed-attempts = true;
                    ignore-empty-password = true;

                    color = noHash palette.surface;
                    font = biryani_theming.fonts.main.name;
                    inside-color = noHash palette.surface_container;
                    line-color = noHash palette.outline_variant;
                    ring-color = noHash palette.primary;
                    text-color = noHash palette.on_surface;
                    layout-bg-color = noHash palette.surface;
                    layout-text-color = noHash palette.on_surface;
                    inside-clear-color = noHash palette.secondary_container;
                    line-clear-color = noHash palette.outline_variant;
                    ring-clear-color = noHash palette.secondary;
                    text-clear-color = noHash palette.on_secondary_container;
                    inside-ver-color = noHash palette.primary_container;
                    line-ver-color = noHash palette.outline_variant;
                    ring-ver-color = noHash palette.primary;
                    text-ver-color = noHash palette.on_primary_container;
                    inside-wrong-color = noHash palette.error_container;
                    line-wrong-color = noHash palette.outline_variant;
                    ring-wrong-color = noHash palette.error;
                    text-wrong-color = noHash palette.on_error_container;
                    bs-hl-color = noHash palette.error;
                    key-hl-color = noHash palette.primary;
                    text-caps-lock-color = noHash palette.on_surface;
                };
            };
        };
}
