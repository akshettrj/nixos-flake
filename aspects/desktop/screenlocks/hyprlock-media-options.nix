{ config, lib, ... }: {
    # Single source of truth for the Hyprlock cursor/media options. Imported into
    # both module graphs: the NixOS aggregator (aspects/desktop/options.nix) so
    # hosts can set values, and the home consumer (hyprlock-home.nix) so it can
    # read them. home-bridge.nix forwards the NixOS-set values into the home graph.
    options.biryani.programs.screenlocks.hyprlock = {
        hide_cursor = lib.mkOption {
            type = lib.types.bool;
            default = !config.biryani.programs.screenlocks.hyprlock.media_controls.enable;
            defaultText = "!config.biryani.programs.screenlocks.hyprlock.media_controls.enable";
            description = ''
                Hide the mouse pointer on the lock screen. Defaults to off when the
                media controls are enabled, since their widgets are clicked and an
                invisible pointer makes them unusable.
            '';
        };

        media_controls = {
            enable = lib.mkEnableOption "clickable MPRIS media controls on the Hyprlock screen" // {
                default = true;
            };

            players = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                example = [
                    "mpv"
                    "firefox"
                ];
                description = ''
                    MPRIS players the controls act on, in priority order, passed to
                    `playerctl --player`. Empty means every available player.
                '';
            };

            ignored_players = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                example = [ "chromium" ];
                description = "MPRIS players the controls skip, passed to `playerctl --ignore-player`.";
            };

            update_interval = lib.mkOption {
                type = lib.types.ints.positive;
                default = 1000;
                description = "Milliseconds between media state refreshes on the lock screen.";
            };

            separator = lib.mkOption {
                type = lib.types.str;
                default = " · ";
                description = "Text placed between the artist and the title.";
            };

            max_artist_length = lib.mkOption {
                type = lib.types.ints.positive;
                default = 25;
                description = "Artist name is truncated to this many characters.";
            };

            max_title_length = lib.mkOption {
                type = lib.types.ints.positive;
                default = 45;
                description = "Track title is truncated to this many characters.";
            };

            icons = {
                previous = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    description = "Glyph for the previous-track button.";
                };
                next = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    description = "Glyph for the next-track button.";
                };
                pause = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    description = "Glyph shown on the toggle button while media is playing, so it names the click action.";
                };
                play = lib.mkOption {
                    type = lib.types.str;
                    default = "";
                    description = "Glyph shown on the toggle button while media is paused, so it names the click action.";
                };
            };

            position = {
                x = lib.mkOption {
                    type = lib.types.int;
                    default = 0;
                    description = "Horizontal position of the media text, relative to the center.";
                };
                y = lib.mkOption {
                    type = lib.types.int;
                    default = -120;
                    description = "Vertical position of the media text, relative to the center.";
                };
            };

            icon_offset = lib.mkOption {
                type = lib.types.int;
                default = 45;
                description = "Pixels below the media text where the button row sits.";
            };

            icon_spacing = lib.mkOption {
                type = lib.types.ints.positive;
                default = 60;
                description = "Horizontal pixels between the media buttons.";
            };

            text_font_size = lib.mkOption {
                type = lib.types.ints.positive;
                default = config.biryani.programs.screenlocks.hyprlock.font_size;
                defaultText = "config.biryani.programs.screenlocks.hyprlock.font_size";
                description = "Font size of the media text.";
            };

            icon_font_size = lib.mkOption {
                type = lib.types.ints.positive;
                default = config.biryani.programs.screenlocks.hyprlock.font_size + 6;
                defaultText = "config.biryani.programs.screenlocks.hyprlock.font_size + 6";
                description = "Font size of the media buttons.";
            };
        };
    };
}
