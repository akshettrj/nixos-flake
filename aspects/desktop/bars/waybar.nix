{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_bars = config.biryani.programs.bars;
            biryani_hw = config.biryani.hardware;
            biryani_media = config.biryani.programs.media;
            biryani_notifiers = config.biryani.programs.notification_daemons;
            biryani_services = config.biryani.services;
            biryani_sys = config.biryani.system;
            biryani_theming = config.biryani.theming;
            palette =
                if biryani_theming.matugen.integrations.waybar.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;

            dunst_monitor_script =
                let
                    dbus-monitor = "${pkgs.dbus}/bin/dbus-monitor";
                    dunstctl = "${pkgs.dunst}/bin/dunstctl";
                in
                pkgs.writeShellScriptBin "dunst_monitor" ''
                    set -euo pipefail

                    readonly ENABLED=''
                    readonly DISABLED=''

                    ${dbus-monitor} path='/org/freedesktop/Notifications',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged' --profile |
                    while read -r _; do
                        PAUSED="$(${dunstctl} is-paused)"
                        if [ "$PAUSED" == 'false' ]; then
                            CLASS="enabled"
                            TEXT="$ENABLED"
                        else
                            CLASS="disabled"
                            TEXT="$DISABLED"
                            COUNT="$(${dunstctl} count waiting)"
                            if [ "$COUNT" != '0' ]; then
                                TEXT="$DISABLED ($COUNT)"
                            fi
                        fi
                        printf '%s \n' "$TEXT"
                    done
                '';

            # RTMIN offset used to make the awcc module refresh immediately after a
            # mode change. Kept in one place so the module and the script agree.
            awcc_signal = 8;
            awcc_mode_script =
                let
                    awcc = "${inputs.awcc.packages.${pkgs.stdenv.hostPlatform.system}.awcc}/bin/awcc";
                    pkill = "${pkgs.procps}/bin/pkill";
                in
                pkgs.writeShellScriptBin "awcc_mode" ''
                    set -uo pipefail

                    readonly AWCC='${awcc}'
                    readonly PKILL='${pkill}'
                    readonly SIGNAL='${toString awcc_signal}'

                    # Cycle order, as normalised keys, with the matching `awcc` set
                    # command for each entry. Keep both arrays in the same order.
                    readonly KEYS=("quiet" "balanced" "performance" "cool" "fullspeed" "gmode")
                    readonly CMDS=("q" "b" "p" "c" "fs" "g")

                    # Read the live mode reported by the awcc daemon (no root needed).
                    current_mode() {
                        local out
                        out="$("$AWCC" qm 2>/dev/null || true)"
                        printf '%s' "''${out##*Current Mode: }"
                    }

                    # Collapse a display name to a lookup key: lowercase, no spaces/hyphens.
                    norm() {
                        local s="''${1,,}"
                        s="''${s// /}"
                        s="''${s//-/}"
                        printf '%s' "$s"
                    }

                    icon_for() {
                        case "$1" in
                            quiet)       printf '󰖔' ;;
                            balanced)    printf '󰈐' ;;
                            performance) printf '󰓅' ;;
                            cool)        printf '󰜗' ;;
                            fullspeed)   printf '󰈸' ;;
                            gmode)       printf '󰉁' ;;
                            manual)      printf '󰖷' ;;
                            *)           printf '󰈐' ;;
                        esac
                    }

                    index_of() {
                        local key="$1" i
                        for i in "''${!KEYS[@]}"; do
                            if [ "''${KEYS[$i]}" = "$key" ]; then
                                printf '%s' "$i"
                                return 0
                            fi
                        done
                        printf '%s' "-1"
                    }

                    refresh() {
                        "$PKILL" -RTMIN+"$SIGNAL" waybar >/dev/null 2>&1 || true
                    }

                    case "''${1:-status}" in
                        status)
                            mode="$(current_mode)"
                            [ -n "$mode" ] || mode="Unknown"
                            key="$(norm "$mode")"
                            printf '{"text":"%s  %s","tooltip":"Thermal mode: %s\\nLeft click: next mode\\nRight click: previous mode","class":"%s","alt":"%s"}\n' \
                                "$(icon_for "$key")" "$mode" "$mode" "$key" "$key"
                            ;;
                        next | prev)
                            key="$(norm "$(current_mode)")"
                            idx="$(index_of "$key")"
                            n="''${#KEYS[@]}"
                            if [ "$idx" -lt 0 ]; then
                                target=0
                            elif [ "''${1}" = "next" ]; then
                                target=$(( (idx + 1) % n ))
                            else
                                target=$(( (idx - 1 + n) % n ))
                            fi
                            "$AWCC" "''${CMDS[$target]}" >/dev/null 2>&1 || true
                            refresh
                            ;;
                        set)
                            idx="$(index_of "$(norm "''${2:-}")")"
                            if [ "$idx" -ge 0 ]; then
                                "$AWCC" "''${CMDS[$idx]}" >/dev/null 2>&1 || true
                                refresh
                            fi
                            ;;
                        *)
                            printf 'usage: awcc_mode {status|next|prev|set <mode>}\n' >&2
                            exit 1
                            ;;
                    esac
                '';
        in
        lib.mkIf (biryani_bars.enable && biryani_bars.waybar.enable) {
            programs.waybar = {
                enable = true;
                package = (
                    if biryani_bars.waybar.use_official_package then
                        inputs.waybar.packages."${pkgs.stdenv.hostPlatform.system}".waybar
                    else
                        pkgs.waybar
                );
                systemd = {
                    enable = true;
                    targets = [ biryani_bars.waybar.systemd_target ];
                };
                settings =
                    let
                        modules = {
                            "custom/separator" = {
                                format = "|";
                                interval = "once";
                                tooltip = false;
                            };
                            clock = {
                                timezone = biryani_sys.time_zone;
                                format = "{:%H:%M:%S - %d-%m-%Y}";
                                tooltip-format = ''
                                    {calendar}
                                '';
                                interval = 10;
                                calendar = {
                                    mode = "year";
                                    mode-mon-col = 4;
                                    weeks-pos = "left";
                                    format = {
                                        today = "<b><u>{}</u></b>";
                                        months = "<span color='#ffead3'><b>{}</b></span>";
                                        days = "<span color='#ecc6d9'><b>{}</b></span>";
                                        weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                                        weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                                    };
                                };
                            };
                            tray = {
                                icon-size = biryani_bars.waybar.icon_size;
                                spacing = biryani_bars.waybar.tray_spacing;
                            };
                            backlight = {
                                format = "{icon} {percent}%";
                                on-scroll-up = "brightnessup 1";
                                on-scroll-down = "brightnessdown 1";
                                # format-icons = [ "󰃚" "󰃛" "󰃜" "󰃝" "󰃞" "󰃟" "󰃠" ];
                                format-icons = [ "󰃠" ];
                            };
                            cpu = {
                                format = "  {usage}%";
                                tooltip = false;
                            };
                            memory = {
                                interval = 5;
                                format = "  {}%";
                                max-length = 10;
                            };
                            battery = {
                                states = {
                                    warning = 40;
                                    critical = 25;
                                };
                                format = " {icon}  {capacity}% ";
                                format-charging = "  {capacity}% ";
                                format-plugged = "  {capacity}% ";
                                format-alt = " {icon} {time} ";
                                # format-icons = [ "" "" "" "" "" ];
                                format-icons = [ "" ];
                                tooltip-format = "{timeTo} (Health: {health})";
                                interval = 10;
                            };
                            "hyprland/workspaces" = {
                                all-outputs = false;
                                show-special = true;
                                format = "{id}";
                                format-icons = {
                                    urgent = "";
                                    active = "";
                                    default = "";
                                };
                                on-scroll-up = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'";
                                on-scroll-down = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'";
                                on-click = "activate";
                            };
                            "hyprland/window" = {
                                max-length = 200;
                                separate-outputs = true;
                                format = "{title}";
                                icon = true;
                                icon-size = biryani_bars.waybar.icon_size;
                            };
                            "hyprland/windowcount" = {
                                format = "[{}] window(s)";
                                separate-outputs = true;
                            };
                            "hyprland/submap" = {
                                format = "  󰌌  [{}]";
                                always-on = true;
                                default-submap = "NA";
                            };
                            network = {
                                format-wifi = "  {bandwidthDownBytes} 󰇚 {bandwidthUpBytes} 󰕒";
                                format-ethernet = "󰈀  {bandwidthDownBytes} 󰇚 {bandwidthUpBytes} 󰕒";
                                format-linked = "  {ifname}";
                                format-disconnected = "Net NA";
                                tooltip-format = "[{ifname}] {essid} via {ipaddr}";
                                interval = 5;
                            };
                            "pulseaudio#output" = {
                                format = "{icon}  {volume}%";
                                format-muted = "󰝟 {volume}%";
                                format-bluetooth = "{icon}  {volume}%";
                                format-bluetooth-muted = "{icon}  {volume}%";
                                format-icons = {
                                    headphone = "";
                                    hands-free = "󰏳";
                                    headset = "󰋎";
                                    phone = "";
                                    portable = "";
                                    car = "";
                                    hdmi = "󰡁";
                                    # default = [ "" "" "" ];
                                    default = [ "" ];
                                };
                            }
                            // lib.optionalAttrs biryani_services.pipewire.enable {
                                on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                                on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
                                on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
                            }
                            // lib.optionalAttrs biryani_hw.pulseaudio.enable {
                                on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
                                on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
                                on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
                            };
                            "pulseaudio#input" = {
                                format = "{format_source}";
                                format-source = " {volume}%";
                                format-source-muted = " {volume}%";
                            }
                            // lib.optionalAttrs biryani_services.pipewire.enable {
                                on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
                                on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%+";
                                on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%-";
                            }
                            // lib.optionalAttrs biryani_hw.pulseaudio.enable {
                                on-click = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
                                on-scroll-up = "pactl set-source-volume @DEFAULT_SOURCE@ +1%";
                                on-scroll-down = "pactl set-source-volume @DEFAULT_SOURCE@ -1%";
                            };
                            privacy = {
                                icon-size = biryani_bars.waybar.icon_size;
                                transition-duration = 100;
                                modules = [
                                    {
                                        type = "screenshare";
                                        tooltip = true;
                                        tooltip-icon-size = biryani_bars.waybar.icon_size;
                                    }
                                    {
                                        type = "audio-out";
                                        tooltip = true;
                                        tooltip-icon-size = biryani_bars.waybar.icon_size;
                                    }
                                    {
                                        type = "audio-in";
                                        tooltip = true;
                                        tooltip-icon-size = biryani_bars.waybar.icon_size;
                                    }
                                ];
                            };
                            mpd =
                                let
                                    mpc = "${pkgs.mpc}/bin/mpc";
                                in
                                {
                                    format = "{stateIcon} [{songPosition}/{queueLength}] {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S})";
                                    format-paused = "{stateIcon} [{songPosition}/{queueLength}] {title}";
                                    format-stopped = "  {consumeIcon}{randomIcon}{repeatIcon}{singleIcon} Stopped";
                                    format-disconnected = "  Disconnected";
                                    unknown-tag = "N/A";
                                    consume-icons = {
                                        on = " ";
                                    };
                                    random-icons = {
                                        off = "<span color=\"#f53c3c\"></span> ";
                                        on = " ";
                                    };
                                    repeat-icons = {
                                        on = " ";
                                    };
                                    single-icons = {
                                        on = "1 ";
                                    };
                                    state-icons = {
                                        paused = "";
                                        playing = "";
                                    };
                                    tooltip-format = "{stateIcon} {title} - {album} ({artist})";
                                    tooltip-format-disconnected = "MPD (disconnected)";
                                    on-click = "${mpc} -q prev";
                                    on-click-middle = "${mpc} -q toggle";
                                    on-click-right = "${mpc} -q next";
                                    on-scroll-up = "${mpc} -q seek '+00:00:02'";
                                    on-scroll-down = "${mpc} -q seek '-00:00:02'";
                                };
                            mpris =
                                let
                                    playerctl = "${pkgs.playerctl}/bin/playerctl";
                                in
                                {
                                    interval = 1;
                                    format-playing = "{status_icon} {player_icon} {dynamic}";
                                    format-paused = "{status_icon} {player_icon} {dynamic}";
                                    format-stopped = "";
                                    tooltip-format = "{player} - {status} - {dynamic}";
                                    on-click = "${playerctl} previous";
                                    on-click-middle = "${playerctl} play-pause";
                                    on-click-right = "${playerctl} next";
                                    on-scroll-up = "${playerctl} position '2+'";
                                    on-scroll-down = "${playerctl} position '2-'";
                                    player-icons = {
                                        default = "";
                                        firefox = " 󰈹 ";
                                        chromium = "  ";
                                        brave = "  ";
                                        mpv = " 󰨜 ";
                                    };
                                    status-icons = {
                                        paused = "";
                                        playing = "";
                                        stopped = "";
                                    };
                                    dynamic-len = -1;
                                    dynamic-importance-order = [
                                        "position"
                                        "length"
                                        "title"
                                        "artist"
                                        "album"
                                    ];
                                };
                            "custom/dunst" =
                                let
                                    dunstctl = "${pkgs.dunst}/bin/dunstctl";
                                in
                                {
                                    exec = "${dunst_monitor_script}/bin/dunst_monitor";
                                    on-click = "${dunstctl} set-paused toggle";
                                    tooltip = "Dunst";
                                    restart-interval = 1;
                                };
                            "custom/swaync" =
                                let
                                    swaync-client = "${pkgs.swaynotificationcenter}/bin/swaync-client";
                                in
                                {
                                    format = "";
                                    on-click = "${swaync-client} -t";
                                    on-click-right = "${swaync-client} -d";
                                    tooltip = "Notifications";
                                };
                        }
                        // lib.optionalAttrs biryani_bars.waybar.awcc.enable {
                            "custom/awcc" = {
                                exec = "${awcc_mode_script}/bin/awcc_mode status";
                                return-type = "json";
                                interval = 5;
                                signal = awcc_signal;
                                on-click = "${awcc_mode_script}/bin/awcc_mode next";
                                on-click-right = "${awcc_mode_script}/bin/awcc_mode prev";
                                on-scroll-up = "${awcc_mode_script}/bin/awcc_mode next";
                                on-scroll-down = "${awcc_mode_script}/bin/awcc_mode prev";
                                tooltip = true;
                            };
                        };
                    in
                    {
                        top_bar = {
                            name = "top-bar";
                            layer = "top";
                            position = "top";
                            height = biryani_bars.waybar.heights;
                            spacing = 0;

                            modules-left = [
                                "hyprland/submap"
                                "custom/separator"
                                "hyprland/workspaces"
                                "custom/separator"
                                "hyprland/windowcount"
                                "custom/separator"
                                "hyprland/window"
                            ];
                            modules-center = [
                                "custom/separator"
                                "clock"
                                "custom/separator"
                            ];
                            modules-right =
                                [ ]
                                ++ lib.optionals biryani_services.pipewire.enable [
                                    "privacy"
                                    "custom/separator"
                                ]
                                ++ lib.optionals (biryani_notifiers.enable && biryani_notifiers.dunst.enable) [
                                    "custom/dunst"
                                    "custom/separator"
                                ]
                                ++ lib.optionals (biryani_notifiers.enable && biryani_notifiers.swaync.enable) [
                                    "custom/swaync"
                                    "custom/separator"
                                ]
                                ++ [
                                    "network"
                                    "custom/separator"
                                ]
                                ++ lib.optionals biryani_bars.waybar.awcc.enable [
                                    "custom/awcc"
                                    "custom/separator"
                                ]
                                ++ lib.optionals biryani_bars.waybar.is_laptop [
                                    "battery"
                                    "custom/separator"
                                    "backlight"
                                    "custom/separator"
                                ]
                                ++ lib.optionals (biryani_services.pipewire.enable || biryani_hw.pulseaudio.enable) [
                                    "pulseaudio#output"
                                    "custom/separator"
                                    "pulseaudio#input"
                                    "custom/separator"
                                ]
                                ++ [ "tray" ];
                        }
                        // modules;

                        bottom_bar = {
                            name = "bottom-bar";
                            layer = "bottom";
                            position = "bottom";
                            height = biryani_bars.waybar.heights;
                            spacing = 0;
                            modules-left = lib.optionals biryani_media.services.mpris.enable [ "mpris" ];
                            modules-center = [ ];
                            modules-right = lib.optionals biryani_media.audio.mpd.enable [ "mpd" ];
                        }
                        // modules;
                    };

                style =
                    # css
                    ''

                        * {
                            font-family: ${biryani_theming.fonts.main.name}, ${
                                lib.strings.concatStringsSep "," (map (font: font.name) (biryani_theming.fonts.backups))
                            };
                            font-size: ${toString (biryani_bars.waybar.font_size)}px;
                        }

                        tooltip {
                            background-color: ${palette.surface_container_high};
                            color: ${palette.on_surface};
                            border: 1px solid ${palette.outline};
                        }

                        window#waybar {
                            background-color: ${palette.surface};
                            color: ${palette.on_surface};
                            border: 3px solid ${palette.outline_variant};
                            padding: 3px;
                        }

                        #workspaces button {
                            padding: 1px;
                            color: ${palette.on_surface};
                        }

                        #workspaces button.active {
                            background-color: ${palette.primary_container};
                            color: ${palette.on_primary_container};
                        }

                        #workspaces button.urgent {
                            background-color: ${palette.error_container};
                            color: ${palette.on_error_container};
                        }

                        #custom-separator {
                            color: ${palette.outline};
                            margin: 0 3px;
                            font-size: ${toString (biryani_bars.waybar.separator_size)}px;
                        }

                        #pulseaudio {
                            background-color: ${palette.surface_container};
                            color: ${palette.on_surface};
                            padding: 2px;
                        }

                        #pulseaudio.input.source-muted {
                            background-color: ${palette.error_container};
                            color: ${palette.on_error_container};
                        }

                        #pulseaudio.output.muted {
                            background-color: ${palette.error_container};
                            color: ${palette.on_error_container};
                        }

                        #tray {
                            padding-right: 6px;
                        }

                        #mpd, #mpris {
                            margin: 0px 6px;
                        }

                        #battery.warning {
                            background-color: ${palette.primary_container};
                            color: ${palette.on_primary_container};
                        }

                        #battery.critical {
                            background-color: ${palette.error_container};
                            color: ${palette.on_error_container};
                        }

                        /* Give notification glyphs breathing room so they are not
                           clipped on the right edge. */
                        #custom-dunst, #custom-swaync {
                            padding: 0 8px;
                        }

                        #custom-awcc {
                            background-color: ${palette.surface_container};
                            color: ${palette.on_surface};
                            padding: 0 6px;
                        }

                        #custom-awcc.quiet {
                            background-color: ${palette.secondary_container};
                            color: ${palette.on_secondary_container};
                        }

                        #custom-awcc.performance,
                        #custom-awcc.fullspeed,
                        #custom-awcc.gmode {
                            background-color: ${palette.error_container};
                            color: ${palette.on_error_container};
                        }

                        #custom-awcc.cool {
                            background-color: ${palette.primary_container};
                            color: ${palette.on_primary_container};
                        }

                    '';
            };
        };
}
