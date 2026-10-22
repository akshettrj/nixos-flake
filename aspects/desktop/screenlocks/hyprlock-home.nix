{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    imports = [ ./hyprlock-media-options.nix ];

    options.biryani.programs.screenlocks.hyprlock = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Hyprlock through Home Manager.";
        };
        font_size = lib.mkOption {
            type = lib.types.ints.positive;
            default = 16;
            description = "Base font size used by Hyprlock text widgets.";
        };
    };

    config =
        let
            biryani_screenlocks = config.biryani.programs.screenlocks;
            biryani_theming = config.biryani.theming;
            base_font_size = biryani_screenlocks.hyprlock.font_size;
            seconds_font_size = base_font_size * 2 + 4;
            time_font_size = base_font_size * 6 + 12;
            palette =
                if biryani_theming.matugen.integrations.hyprlock.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;

            screenlocks_meta = import ../../core/metadata/programs/screenlocks.nix {
                inherit config inputs pkgs;
            };

            media = biryani_screenlocks.hyprlock.media_controls;

            # `playerctl` invocation shared by the lock screen widgets and their
            # click actions, so player selection is configured in one place.
            playerctl_cli = lib.escapeShellArgs (
                [ "${pkgs.playerctl}/bin/playerctl" ]
                ++ lib.optional (media.players != [ ]) "--player=${lib.concatStringsSep "," media.players}"
                ++ lib.optional (
                    media.ignored_players != [ ]
                ) "--ignore-player=${lib.concatStringsSep "," media.ignored_players}"
            );

            # Hyprlock labels can only run a command and print a string, so one
            # script answers every widget: the track text and each button glyph.
            # Glyphs stay empty while no player is around, which hides the whole
            # row instead of showing dead buttons.
            media_script = pkgs.writeShellApplication {
                name = "hyprlock-media";
                runtimeInputs = [ pkgs.coreutils ];
                text = ''
                    playerctl=(${playerctl_cli})

                    status="$("''${playerctl[@]}" status 2>/dev/null || true)"

                    metadata() {
                        "''${playerctl[@]}" metadata --format "$1" 2>/dev/null || true
                    }

                    case "''${1:-}" in
                    text)
                        if [ -n "$status" ]; then
                            artist="$(metadata '{{markup_escape(trunc(artist, ${toString media.max_artist_length}))}}')"
                            title="$(metadata '{{markup_escape(trunc(title, ${toString media.max_title_length}))}}')"
                            if [ -n "$artist" ] && [ -n "$title" ]; then
                                printf '%s%s%s' "$artist" ${lib.escapeShellArg media.separator} "$title"
                            else
                                printf '%s' "$artist$title"
                            fi
                        fi
                        ;;
                    toggle-icon)
                        if [ "$status" = "Playing" ]; then
                            printf '%s' ${lib.escapeShellArg media.icons.pause}
                        elif [ -n "$status" ]; then
                            printf '%s' ${lib.escapeShellArg media.icons.play}
                        fi
                        ;;
                    previous-icon)
                        if [ -n "$status" ]; then
                            printf '%s' ${lib.escapeShellArg media.icons.previous}
                        fi
                        ;;
                    next-icon)
                        if [ -n "$status" ]; then
                            printf '%s' ${lib.escapeShellArg media.icons.next}
                        fi
                        ;;
                    esac
                '';
            };

            mediaLabel =
                {
                    argument,
                    x,
                    y,
                    font_size,
                    color,
                    onclick ? null,
                }:
                ''
                    label {
                        text = cmd[update:${toString media.update_interval}] ${media_script}/bin/hyprlock-media ${argument}
                        color = ${color}
                        font_size = ${toString font_size}
                        font_family = ${biryani_theming.fonts.main.name}
                        position = ${toString x}, ${toString y}
                        halign = center
                        valign = center${lib.optionalString (onclick != null) "\n    onclick = ${onclick}"}
                    }
                '';

            media_icon_y = media.position.y - media.icon_offset;
            media_widgets = lib.concatStringsSep "\n" [
                (mediaLabel {
                    argument = "text";
                    x = media.position.x;
                    y = media.position.y;
                    font_size = media.text_font_size;
                    color = "rgba(${lib.removePrefix "#" palette.on_surface_variant}e6)";
                })
                (mediaLabel {
                    argument = "previous-icon";
                    x = media.position.x - media.icon_spacing;
                    y = media_icon_y;
                    font_size = media.icon_font_size;
                    color = "rgb(${lib.removePrefix "#" palette.primary})";
                    onclick = "${playerctl_cli} previous";
                })
                (mediaLabel {
                    argument = "toggle-icon";
                    x = media.position.x;
                    y = media_icon_y;
                    font_size = media.icon_font_size;
                    color = "rgb(${lib.removePrefix "#" palette.primary})";
                    onclick = "${playerctl_cli} play-pause";
                })
                (mediaLabel {
                    argument = "next-icon";
                    x = media.position.x + media.icon_spacing;
                    y = media_icon_y;
                    font_size = media.icon_font_size;
                    color = "rgb(${lib.removePrefix "#" palette.primary})";
                    onclick = "${playerctl_cli} next";
                })
            ];
        in
        lib.mkIf (biryani_screenlocks.enable && biryani_screenlocks.hyprlock.enable) {
            xdg.configFile."hypr/hyprlock.conf".text = ''

                general {
                    disable_loading_bar = true
                    hide_cursor = ${lib.boolToString biryani_screenlocks.hyprlock.hide_cursor}
                    grace = 2
                    no_fade_in = false
                    no_fade_out = false
                    ignore_empty_input = true
                    pam_module = hyprlock
                }

                background {
                    path = ${biryani_theming.wallpaper}
                    color = rgb(${lib.removePrefix "#" palette.surface})
                    blur_passes = 4
                    blur_size = 10
                    contrast = 0.9
                    brightness = 0.65
                    vibrancy = 0.17
                    vibrancy_darkness = 0.0
                }

                label {
                    text = cmd[update:60000] ${pkgs.bash}/bin/bash -c 'hour=$(${pkgs.coreutils}/bin/date +%H); if (( hour < 12 )); then part=Morning; elif (( hour < 17 )); then part=Afternoon; else part=Evening; fi; printf "Good %s, %s" "$part" "$USER"'
                    color = rgba(${lib.removePrefix "#" palette.secondary}e6)
                    font_size = ${toString base_font_size}
                    font_family = ${biryani_theming.fonts.main.name}
                    position = 0, 165
                    halign = center
                    valign = center
                }

                label {
                    text = $TIME
                    color = rgb(${lib.removePrefix "#" palette.primary})
                    font_size = ${toString time_font_size}
                    font_family = ${biryani_theming.fonts.main.name}
                    shadow_passes = 3
                    shadow_size = 5
                    position = -25, 55
                    halign = center
                    valign = center
                }

                label {
                    text = cmd[update:1000] ${pkgs.coreutils}/bin/date +%S
                    color = rgba(${lib.removePrefix "#" palette.tertiary}e6)
                    font_size = ${toString seconds_font_size}
                    font_family = ${biryani_theming.fonts.main.name}
                    position = 198, 37
                    halign = center
                    valign = center
                }

                label {
                    text = cmd[update:60000] ${pkgs.coreutils}/bin/date '+%A, %B %d'
                    color = rgb(${lib.removePrefix "#" palette.secondary})
                    font_size = ${toString base_font_size}
                    font_family = ${biryani_theming.fonts.main.name}
                    position = 0, -60
                    halign = center
                    valign = center
                }
                ${lib.optionalString media.enable ("\n" + media_widgets)}
                input-field {
                    size = 230, 42
                    outline_thickness = 1
                    rounding = -1
                    dots_size = 0.18
                    dots_spacing = 0.15
                    dots_center = true
                    fade_on_empty = false
                    placeholder_text =
                    shadow_passes = 2
                    shadow_size = 4
                    shadow_boost = 1.2
                    outer_color = rgba(${lib.removePrefix "#" palette.outline}cc)
                    inner_color = rgba(${lib.removePrefix "#" palette.surface_container}55)
                    font_color = rgb(${lib.removePrefix "#" palette.primary})
                    check_color = rgb(${lib.removePrefix "#" palette.primary})
                    fail_color = rgb(${lib.removePrefix "#" palette.error})
                    halign = center
                    valign = center
                    position = 0, -245
                }

            '';

            home.packages = [ screenlocks_meta.hyprlock.pkg ];
        };
}
