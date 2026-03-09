{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_bars = config.propheci.programs.bars;
    pro_hw = config.propheci.hardware;
    pro_media = config.propheci.programs.media;
    pro_notifiers = config.propheci.programs.notification_daemons;
    pro_servies = config.propheci.services;
    pro_sys = config.propheci.system;
    pro_theming = config.propheci.theming;

    dunst_monitor_script = let
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
  in
    lib.mkIf (pro_bars.enable && pro_bars.waybar.enable) {
      programs.waybar = {
        enable = true;
        package = (
          if pro_bars.waybar.use_official_package
          then inputs.waybar.packages."${pkgs.system}".waybar
          else pkgs.waybar
        );
        systemd = {
          enable = true;
          target = pro_bars.waybar.systemd_target;
        };
        settings = let
          modules = {
            "custom/separator" = {
              format = "|";
              interval = "once";
              tooltip = false;
            };
            clock = {
              timezone = pro_sys.time_zone;
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
                  today = ''<b><u>{}</u></b>'';
                  months = "<span color='#ffead3'><b>{}</b></span>";
                  days = "<span color='#ecc6d9'><b>{}</b></span>";
                  weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                  weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                };
              };
            };
            tray = {
              icon-size = pro_bars.waybar.icon_size;
              spacing = pro_bars.waybar.tray_spacing;
            };
            backlight = {
              format = "{icon} {percent}%";
              on-scroll-up = "brightnessup 1";
              on-scroll-down = "brightnessdown 1";
              # format-icons = [ "󰃚" "󰃛" "󰃜" "󰃝" "󰃞" "󰃟" "󰃠" ];
              format-icons = ["󰃠"];
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
              format-icons = [""];
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
              on-scroll-up = "hyprctl dispatch workspace e+1";
              on-scroll-down = "hyprctl dispatch workspace e-1";
              on-click = "activate";
            };
            "hyprland/window" = {
              max-length = 200;
              separate-outputs = true;
              format = "{title}";
              icon = true;
              icon-size = pro_bars.waybar.icon_size;
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
            "pulseaudio#output" =
              {
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
                  default = [""];
                };
              }
              // lib.optionalAttrs pro_servies.pipewire.enable {
                on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
                on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
              }
              // lib.optionalAttrs pro_hw.pulseaudio.enable {
                on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
                on-scroll-up = "pactl set-sink-volume @DEFAULT_SINK@ +1%";
                on-scroll-down = "pactl set-sink-volume @DEFAULT_SINK@ -1%";
              };
            "pulseaudio#input" =
              {
                format = "{format_source}";
                format-source = " {volume}%";
                format-source-muted = " {volume}%";
              }
              // lib.optionalAttrs pro_servies.pipewire.enable {
                on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
                on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%+";
                on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%-";
              }
              // lib.optionalAttrs pro_hw.pulseaudio.enable {
                on-click = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
                on-scroll-up = "pactl set-source-volume @DEFAULT_SOURCE@ +1%";
                on-scroll-down = "pactl set-source-volume @DEFAULT_SOURCE@ -1%";
              };
            privacy = {
              icon-size = pro_bars.waybar.icon_size;
              transition-duration = 100;
              modules = [
                {
                  type = "screenshare";
                  tooltip = true;
                  tooltip-icon-size = pro_bars.waybar.icon_size;
                }
                {
                  type = "audio-out";
                  tooltip = true;
                  tooltip-icon-size = pro_bars.waybar.icon_size;
                }
                {
                  type = "audio-in";
                  tooltip = true;
                  tooltip-icon-size = pro_bars.waybar.icon_size;
                }
              ];
            };
            mpd = let
              mpc = "${pkgs.mpc}/bin/mpc";
            in {
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
            mpris = let
              playerctl = "${pkgs.playerctl}/bin/playerctl";
            in {
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
            "custom/dunst" = let
              dunstctl = "${pkgs.dunst}/bin/dunstctl";
            in {
              exec = "${dunst_monitor_script}/bin/dunst_monitor";
              on-click = "${dunstctl} set-paused toggle";
              tooltip = "Dunst";
              restart-interval = 1;
            };
          };
        in {
          top_bar =
            {
              name = "top-bar";
              layer = "top";
              position = "top";
              height = pro_bars.waybar.heights;
              spacing = 0;

              modules-left = [
                "hyprland/submap"
                "custom/separator"
                "hyprland/workspaces"
                "custom/separator"
                "hyprland/window"
              ];
              modules-center = [
                "custom/separator"
                "clock"
                "custom/separator"
              ];
              modules-right =
                []
                ++ lib.optionals pro_servies.pipewire.enable [
                  "privacy"
                  "custom/separator"
                ]
                ++ lib.optionals (pro_notifiers.enable && pro_notifiers.dunst.enable) [
                  "custom/dunst"
                  "custom/separator"
                ]
                ++ [
                  "network"
                  "custom/separator"
                ]
                ++ lib.optionals pro_bars.waybar.is_laptop [
                  "battery"
                  "custom/separator"
                  "backlight"
                  "custom/separator"
                ]
                ++ lib.optionals (pro_servies.pipewire.enable || pro_hw.pulseaudio.enable) [
                  "pulseaudio#output"
                  "custom/separator"
                  "pulseaudio#input"
                  "custom/separator"
                ]
                ++ [
                  "tray"
                ];
            }
            // modules;

          bottom_bar =
            {
              name = "bottom-bar";
              layer = "bottom";
              position = "bottom";
              height = pro_bars.waybar.heights;
              spacing = 0;
              modules-left = lib.optionals pro_media.services.mpris.enable ["mpris"];
              modules-center = [];
              modules-right = lib.optionals pro_media.audio.mpd.enable ["mpd"];
            }
            // modules;
        };

        style =
          # css
          ''

            * {
                font-family: ${pro_theming.fonts.main.name}, ${
              lib.strings.concatStringsSep "," (map (font: font.name) (pro_theming.fonts.backups))
            };
                font-size: ${toString (pro_bars.waybar.font_size)}px;
            }

            tooltip {
                background-color: #000000;
            }

            window#waybar {
                color: #ffffff;
                border: 3px solid rgba(100, 114, 125, 0.5);
                padding: 3px;
            }

            #workspaces button {
                padding: 1px;
                color: #ffffff;
            }

            #workspaces button.active {
                background-color: #64727D;
            }

            #workspaces button.urgent {
                background-color: #eb4d4b;
            }

            #custom-separator {
                color: white;
                margin: 0 3px;
                font-size: ${toString (pro_bars.waybar.separator_size)}px;
            }

            #pulseaudio {
                padding: 2px;
            }

            #pulseaudio.input.source-muted {
                background-color: #90b1b1;
                color: #2a5c45;
            }

            #pulseaudio.output.muted {
                background-color: #90b1b1;
                color: #2a5c45;
            }

            #tray {
                padding-right: 6px;
            }

            #mpd, #mpris {
                margin: 0px 6px;
            }

            #battery.warning {
                background-color: #fcba03;
                color: black;
            }

            #battery.critical {
                background-color: red;
                color: white;
            }

          '';
      };
    };
}
