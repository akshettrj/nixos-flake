{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.programs.screenlocks.hyprlock = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Hyprlock through Home Manager.";
        };

        background_image = lib.mkOption {
            type = lib.types.path;
            description = "Background image used by Hyprlock.";
        };
    };

    config =
        let
            biryani_screenlocks = config.biryani.programs.screenlocks;
            biryani_theming = config.biryani.theming;

            screenlocks_meta = import ../../core/metadata/programs/screenlocks.nix {
                inherit config inputs pkgs;
            };
        in
        lib.mkIf (biryani_screenlocks.enable && biryani_screenlocks.hyprlock.enable) {
            xdg.configFile."hypr/hyprlock.conf".text = ''

                general {
                    disable_loading_bar = false
                    hide_cursor = false
                    grace = 2
                    no_fade_in = false
                    no_fade_out = false
                    ignore_empty_input = true
                    pam_module = hyprlock
                }

                background {
                    path = ${biryani_screenlocks.hyprlock.background_image}
                    blur_passes = 3
                    blur_size = 7
                }

                input-field {
                    size = 250, 60
                    outline_thickness = 2
                    shadow_passes = 3
                    shadow_size = 3
                    shadow_boost = 1.5
                    halign = center
                    valign = center
                    position = 0, -120
                }

            '';

            home.packages = [ screenlocks_meta.hyprlock.pkg ];
        };
}
