{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    imports = [ ./wayland.nix ];

    config =
        let
            biryani_browsers = config.biryani.programs.browsers;
            biryani_clips = config.biryani.programs.clipboard_managers;
            biryani_deskenvs = config.biryani.desktop_environments;
            biryani_file_explorers = config.biryani.programs.file_explorers;
            biryani_launchers = config.biryani.programs.launchers;
            biryani_mpd = config.biryani.programs.media.audio.mpd;
            biryani_mpris = config.biryani.programs.media.services.mpris;
            biryani_services = config.biryani.services;
            biryani_hw = config.biryani.hardware;
            biryani_ss_tools = config.biryani.programs.screenshot_tools;
            biryani_terminals = config.biryani.programs.terminals;
            biryani_theming = config.biryani.theming;

            browsers_meta = import ../../../core/metadata/programs/browsers.nix { inherit pkgs; };
            clips_meta = import ../../../core/metadata/programs/clipboard_managers.nix { inherit pkgs; };
            file_explorers_meta = import ../../../core/metadata/programs/file_explorers.nix { inherit pkgs; };
            launchers_meta = import ../../../core/metadata/programs/launchers.nix { inherit pkgs; };
            screenlocks_meta = import ../../../core/metadata/programs/screenlocks.nix {
                inherit config inputs pkgs;
            };
            ss_tools_meta = import ../../../core/metadata/programs/screenshot_tools.nix { inherit pkgs; };
            terminals_meta = import ../../../core/metadata/programs/terminals.nix {
                inherit config inputs pkgs;
            };

            normal_desktops =
                (
                    lib.range 1 9
                    |> builtins.map toString
                    |> builtins.map (ws: {
                        name = ws;
                        value = ws;
                    })
                    |> lib.listToAttrs
                )
                // {
                    "0" = "10";
                };

            alt_desktops =
                (
                    lib.range 11 19
                    |> builtins.map (ws: {
                        name = toString (ws - 10);
                        value = toString ws;
                    })
                    |> lib.listToAttrs
                )
                // {
                    "0" = "20";
                };

            launcher = biryani_deskenvs.hyprland.launcher;
            ss_tool = biryani_deskenvs.hyprland.screenshot_tool;
            screenlock = biryani_deskenvs.hyprland.screenlock;
            clipboard_manager = biryani_deskenvs.hyprland.clipboard_manager;

            hyprpaper_pkg = (
                if biryani_deskenvs.hyprland.use_official_packages then
                    inputs.hyprpaper.packages."${pkgs.stdenv.hostPlatform.system}".hyprpaper
                else
                    pkgs.hyprpaper
            );
            hyprland_pkg = (
                if biryani_deskenvs.hyprland.use_official_packages then
                    inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".hyprland
                else
                    pkgs.hyprland
            );
            xdg-desktop-portal-hyprland_pkg = (
                if biryani_deskenvs.hyprland.use_official_packages then
                    inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".xdg-desktop-portal-hyprland
                else
                    pkgs.xdg-desktop-portal-hyprland
            );

            startup_script =
                let
                    clipboard_manager_meta = clips_meta."${clipboard_manager}";
                    hyprctl = "${hyprland_pkg}/bin/hyprctl";
                    hyprctlEval = code: "${hyprctl} eval ${lib.escapeShellArg code}";
                    nm-applet = "${pkgs.networkmanagerapplet}/bin/nm-applet";
                    blueman-applet = "${pkgs.blueman}/bin/blueman-applet";
                    pasystray = "${pkgs.pasystray}/bin/pasystray";
                    mullvad-gui = "${pkgs.mullvad-vpn}/bin/mullvad-gui";
                    monitorCommands = map (
                        mon:
                        let
                            mode = "${toString mon.width}x${toString mon.height}@${toString mon.refresh_rate}";
                            position = "${toString mon.x}x${toString mon.y}";
                        in
                        if mon.enabled then
                            hyprctlEval "hl.monitor({ output = ${luaString mon.name}, mode = ${luaString mode}, position = ${luaString position}, scale = ${luaString mon.additional_settings} })"
                        else
                            hyprctlEval "hl.monitor({ output = ${luaString mon.name}, disabled = true })"
                    ) biryani_deskenvs.hyprland.monitors;
                in
                pkgs.writeShellScriptBin "start" ''

                    # Setting up monitors
                    ${lib.strings.concatStringsSep "\n" monitorCommands}

                    pidof ${clipboard_manager_meta.bin} && killall -9 ${clipboard_manager_meta.bin}
                    pidof ${nm-applet} && killall -9 ${nm-applet}
                    pidof ${blueman-applet} && killall -9 ${blueman-applet}
                    pidof ${pasystray} && killall -9 ${pasystray}
                    pidof ${mullvad-gui} && killall -9 ${mullvad-gui}

                    ${clipboard_manager_meta.cmd} &
                    ${nm-applet} &
                    ${blueman-applet} &
                    ${pasystray} &
                    ${mullvad-gui} &
                '';

            kill_window_script =
                let
                    jq = "${pkgs.jq}/bin/jq";
                    xdotool = "${pkgs.xdotool}/bin/xdotool";
                in
                pkgs.writeShellScriptBin "kill_window" ''

                    if [ "$1" = "-f" ]; then
                        current_pid="$(hyprctl activewindow -j | ${jq} -r ".pid")"
                        kill -9 $current_pid
                    else
                        if [ "$(hyprctl activewindow -j | ${jq} -r ".class")" = "Steam" ]; then
                            ${xdotool} getactivewindow windowunmap
                        else
                            hyprctl dispatch 'hl.dsp.window.close()'
                        fi
                    fi

                '';

            luaString = builtins.toJSON;
            luaExecBind = keys: command: "hl.bind(${luaString keys}, hl.dsp.exec_cmd(${luaString command}))";
            luaRepeatingExecBind =
                keys: command:
                "hl.bind(${luaString keys}, hl.dsp.exec_cmd(${luaString command}), { repeating = true })";
            luaFocusDirectionBind =
                keys: direction: "hl.bind(${luaString keys}, hl.dsp.focus({ direction = ${luaString direction} }))";
            luaSwapDirectionBind =
                keys: direction:
                "hl.bind(${luaString keys}, hl.dsp.window.swap({ direction = ${luaString direction} }))";
            luaWorkspaceBind =
                keys: workspace: "hl.bind(${luaString keys}, hl.dsp.focus({ workspace = ${luaString workspace} }))";
            luaMoveWorkspaceBind =
                keys: workspace:
                "hl.bind(${luaString keys}, hl.dsp.window.move({ workspace = ${luaString workspace}, follow = false }))";
            luaWindowMoveBind =
                keys: x: y:
                "hl.bind(${luaString keys}, hl.dsp.window.move({ x = ${toString x}, y = ${toString y}, relative = true }), { repeating = true })";
            luaWindowRule = fields: "hl.window_rule({ ${lib.concatStringsSep ", " fields} })";
            # Workspace-to-monitor rules are declared statically (not applied
            # imperatively from the startup script) so they survive the config
            # reload triggered by `home-manager switch`, which otherwise wipes
            # any workspace rules not present in the static config.
            workspaceRules = lib.concatMap (
                mon:
                map (
                    wk: "hl.workspace_rule({ workspace = ${luaString (toString wk)}, monitor = ${luaString mon.name} })"
                ) (lib.optionals mon.enabled mon.workspaces)
            ) biryani_deskenvs.hyprland.monitors;
            palette =
                if biryani_theming.matugen.integrations.hyprland.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;
            noHash = lib.removePrefix "#";
            rgba = color: alpha: "rgba(${noHash color}${alpha})";
        in
        lib.mkIf (biryani_deskenvs.enable && biryani_deskenvs.hyprland.enable) {
            assertions = [
                {
                    assertion = screenlocks_meta."${screenlock}".wayland;
                    message = "${screenlock} doesn't support Hyprland (Wayland)";
                }
                {
                    assertion = biryani_terminals.enable;
                    message = "Hyprland is enabled but terminals are disabled";
                }
                {
                    assertion = biryani_launchers.enable;
                    message = "Hyprland is enabled but app launchers are disabled";
                }
                {
                    assertion = biryani_launchers."${launcher}".enable;
                    message = "Hyprland's launcher is set to ${launcher} but its configuration is disabled";
                }
                {
                    assertion = biryani_browsers.enable;
                    message = "Hyprland is enabled but browsers are disabled";
                }
                {
                    assertion = biryani_ss_tools.enable;
                    message = "Hyprland is enabled but screenshot tools are disabled";
                }
                {
                    assertion = biryani_ss_tools."${ss_tool}".enable;
                    message = "Hyprland's ss tool is set to ${ss_tool} but its configuration is disabled";
                }
                {
                    assertion = biryani_clips."${clipboard_manager}".enable;
                    message = "Hyprland's clipboard manager is set to ${clipboard_manager} but its configuration is disabled";
                }
            ];

            biryani.desktop_environments.wayland.enable = lib.mkForce true;

            wayland.windowManager.hyprland = {
                enable = true;
                configType = "lua";

                package = hyprland_pkg;
                portalPackage = xdg-desktop-portal-hyprland_pkg;

                systemd = {
                    enable = true;
                    variables = [ "--all" ];
                };
                xwayland.enable = true;

                extraConfig =
                    let
                        ydotool = "${pkgs.ydotool}/bin/ydotool";

                        ss_group_help = "- Escape: Abort\\n- R: Region\\n- F: Fullscreen\\n- H: This help";
                    in
                    ''
                        hl.on("hyprland.start", function()
                          hl.exec_cmd(${luaString "${startup_script}/bin/start"})
                        end)

                        -- Workspace to monitor mapping (kept in static config so it
                        -- survives config reloads triggered by home-manager switch)
                        ${lib.concatStringsSep "\n" workspaceRules}

                        hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
                        hl.env("XDG_SESSION_TYPE", "wayland")
                        hl.env("XDG_SESSION_DESKTOP", "Hyprland")
                        hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
                        hl.env("QT_QPA_PLATFORM", "wayland;xcb")
                        hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
                        ${lib.optionalString (biryani_theming.qt && biryani_theming.matugen.integrations.qt.enable) ''
                            hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
                            hl.env("QT_STYLE_OVERRIDE", "qt6ct-style")
                            hl.env("QT_PLUGIN_PATH", "${config.home.profileDirectory}/lib/qt-6/plugins")
                        ''}
                        hl.env("SDL_VIDEODRIVER", "wayland")
                        hl.env("LIBSEAT_BACKEND", "logind")
                        ${lib.optionalString (biryani_theming.gtk && biryani_theming.matugen.integrations.gtk.enable) ''
                            hl.env("GTK_THEME", ${
                                luaString (if biryani_theming.matugen.mode == "dark" then "adw-gtk3-dark" else "adw-gtk3")
                            })
                        ''}
                        hl.env("XCURSOR_THEME", ${luaString biryani_theming.cursor.name})
                        hl.env("XCURSOR_SIZE", ${luaString (toString biryani_theming.cursor.size)})
                        ${lib.optionalString (launcher == "bemenu") ''
                            hl.env("BEMENU_OPTS", ${luaString config.home.sessionVariables.BEMENU_OPTS})
                        ''}
                        ${lib.optionalString biryani_hw.nvidia.enable (
                            if biryani_hw.nvidia.prime.enable then
                                # PRIME offload: compositor + apps render on the Intel
                                # iGPU by default, so VAAPI must use the Intel driver.
                                # NVIDIA is only used when explicitly offloaded.
                                ''
                                    hl.env("LIBVA_DRIVER_NAME", "iHD")
                                    hl.env("WLR_NO_HARDWARE_CURSORS", "1")
                                ''
                            else
                                ''
                                    hl.env("LIBVA_DRIVER_NAME", "nvidia")
                                    hl.env("NVD_BACKEND", "direct")
                                    hl.env("WLR_NO_HARDWARE_CURSORS", "1")
                                ''
                        )}

                        hl.config({
                          xwayland = {
                            force_zero_scaling = true,
                          },
                          input = {
                            kb_layout = "us",
                            kb_options = "caps:swapescape",
                            repeat_rate = 50,
                            repeat_delay = 220,
                            follow_mouse = 2,
                            touchpad = {
                              disable_while_typing = true,
                              natural_scroll = false,
                              scroll_factor = ${toString biryani_deskenvs.hyprland.scroll_factor},
                              tap_and_drag = true,
                              tap_to_click = false,
                              drag_lock = 1,
                            },
                          },
                          cursor = {
                            no_hardware_cursors = true,
                            use_cpu_buffer = 0,
                          },
                          general = {
                            gaps_in = 2,
                            gaps_out = 2,
                            border_size = 2,
                            col = {
                              active_border = { colors = { ${luaString (rgba palette.primary "ee")}, ${luaString (rgba palette.secondary "ee")} }, angle = 45 },
                              inactive_border = ${luaString (rgba palette.outline "aa")},
                            },
                            layout = "dwindle",
                            no_focus_fallback = true,
                            resize_on_border = true,
                          },
                          decoration = {
                            rounding = 0,
                            blur = {
                              enabled = true,
                              size = 3,
                              passes = 1,
                              xray = false,
                            },
                            shadow = {
                              enabled = true,
                              range = 4,
                              render_power = 3,
                              color = ${luaString (rgba palette.surface_container_lowest "ee")},
                            },
                          },
                          animations = {
                            enabled = false,
                          },
                          dwindle = {
                            preserve_split = true,
                          },
                          master = {
                            new_status = "master",
                          },
                          debug = {
                            vfr = false,
                          },
                          misc = {
                            disable_hyprland_logo = true,
                            disable_splash_rendering = true,
                            animate_manual_resizes = true,
                            animate_mouse_windowdragging = true,
                            disable_autoreload = false,
                            enable_swallow = true,
                            focus_on_activate = false,
                          },
                        })

                        hl.device({
                          name = "epic-mouse-v1",
                          sensitivity = -0.5,
                        })

                        ${lib.concatStringsSep "\n" (
                            [
                                (luaFocusDirectionBind "SUPER + H" "left")
                                (luaFocusDirectionBind "SUPER + L" "right")
                                (luaFocusDirectionBind "SUPER + K" "up")
                                (luaFocusDirectionBind "SUPER + J" "down")
                                (luaSwapDirectionBind "SUPER + SHIFT + H" "left")
                                (luaSwapDirectionBind "SUPER + SHIFT + L" "right")
                                (luaSwapDirectionBind "SUPER + SHIFT + K" "up")
                                (luaSwapDirectionBind "SUPER + SHIFT + J" "down")
                            ]
                            ++ (builtins.attrValues (
                                builtins.mapAttrs (key: desk: luaWorkspaceBind "SUPER + ${key}" desk) normal_desktops
                            ))
                            ++ (builtins.attrValues (
                                builtins.mapAttrs (key: desk: luaWorkspaceBind "SUPER + ALT + ${key}" desk) alt_desktops
                            ))
                            ++ (builtins.attrValues (
                                builtins.mapAttrs (key: desk: luaMoveWorkspaceBind "SUPER + SHIFT + ${key}" desk) normal_desktops
                            ))
                            ++ (builtins.attrValues (
                                builtins.mapAttrs (key: desk: luaMoveWorkspaceBind "SUPER + ALT + SHIFT + ${key}" desk) alt_desktops
                            ))
                            ++ [
                                (luaWorkspaceBind "SUPER + BracketRight" "m+1")
                                (luaWorkspaceBind "SUPER + BracketLeft" "m-1")
                                (luaWorkspaceBind "SUPER + SHIFT + BracketRight" "r+1")
                                (luaWorkspaceBind "SUPER + SHIFT + BracketLeft" "r-1")
                                (luaExecBind "SUPER + C" "${kill_window_script}/bin/kill_window")
                                ''hl.bind("SUPER + S", hl.dsp.window.float({ action = "toggle" }))''
                                ''hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))''
                                (luaMoveWorkspaceBind "SUPER + MINUS" "special")
                                ''hl.bind("SUPER + M", hl.dsp.window.fullscreen({ mode = "maximized" }))''
                                ''hl.bind("SUPER + U", hl.dsp.focus({ urgent_or_last = true }))''
                                ''hl.bind("SUPER + N", hl.dsp.window.cycle_next({ next = true }))''
                                ''hl.bind("SUPER + P", hl.dsp.window.cycle_next({ next = false }))''
                                ''hl.bind("SUPER + Tab", hl.dsp.focus({ monitor = "+1" }))''
                                ''hl.bind("SUPER + O", hl.dsp.window.move({ monitor = "+1", follow = false }))''
                                ''hl.bind("SUPER + R", hl.dsp.layout("togglesplit"))''
                                (luaExecBind "SUPER + Escape" screenlocks_meta."${screenlock}".cmd)
                                ''hl.bind("SUPER + CONTROL + Q", hl.dsp.exit())''
                                ''hl.bind("SUPER + ALT + S", hl.dsp.window.pin())''
                                (luaExecBind "SUPER + SHIFT + C" "${kill_window_script}/bin/kill_window -f")
                                ''hl.bind("SUPER + SHIFT + MINUS", hl.dsp.workspace.toggle_special())''
                                (luaExecBind "SUPER + Return" terminals_meta."${biryani_terminals.main}".cmd)
                                (luaExecBind "SUPER + SHIFT + Return" terminals_meta."${biryani_terminals.backup}".cmd)
                                (luaExecBind "SUPER + E" "${terminals_meta."${biryani_terminals.main}".exec} ${
                                    file_explorers_meta."${biryani_file_explorers.main}".bin
                                }")
                                (luaExecBind "SUPER + SHIFT + E" "${terminals_meta."${biryani_terminals.main}".exec} ${
                                    file_explorers_meta."${biryani_file_explorers.backup}".bin
                                }")
                                (luaExecBind "SUPER + Space" launchers_meta."${launcher}".bin)
                                (luaExecBind "SUPER + F1" browsers_meta."${biryani_browsers.main}".cmd)
                                (luaExecBind "SUPER + SHIFT + F1" browsers_meta."${biryani_browsers.main}".cmd_shift)
                            ]
                            ++ lib.optionals biryani_services.pipewire.enable [
                                (luaExecBind "SUPER + F6" "wpctl set-mute '@DEFAULT_AUDIO_SINK@' toggle")
                                (luaExecBind "XF86AudioMute" "wpctl set-mute '@DEFAULT_AUDIO_SINK@' toggle")
                            ]
                            ++ lib.optionals biryani_hw.pulseaudio.enable [
                                (luaExecBind "SUPER + F6" "pactl set-sink-mute '@DEFAULT_SINK@' toggle")
                                (luaExecBind "XF86AudioMute" "wpctl set-sink-mute '@DEFAULT_SINK@' toggle")
                            ]
                            ++ lib.optionals biryani_mpd.enable [
                                (luaExecBind "SUPER + F9" "${pkgs.mpc}/bin/mpc -q prev")
                                (luaExecBind "SUPER + F10" "${pkgs.mpc}/bin/mpc -q toggle")
                                (luaExecBind "SUPER + F11" "${pkgs.mpc}/bin/mpc -q next")
                            ]
                            ++ lib.optionals biryani_mpris.enable [
                                (luaExecBind "XF86AudioPrev" "${pkgs.playerctl}/bin/playerctl previous")
                                (luaExecBind "XF86AudioPlay" "${pkgs.playerctl}/bin/playerctl play-pause")
                                (luaExecBind "XF86AudioNext" "${pkgs.playerctl}/bin/playerctl next")
                            ]
                            ++ [
                                (luaWindowMoveBind "SUPER + Left" (-10) 0)
                                (luaWindowMoveBind "SUPER + Right" 10 0)
                                (luaWindowMoveBind "SUPER + Up" 0 (-10))
                                (luaWindowMoveBind "SUPER + Down" 0 10)
                                (luaRepeatingExecBind "XF86MonBrightnessDown" "brightnessdown")
                                (luaRepeatingExecBind "XF86MonBrightnessUp" "brightnessup")
                                (luaRepeatingExecBind "SUPER + F2" "brightnessdown")
                                (luaRepeatingExecBind "SUPER + F3" "brightnessup")
                            ]
                            ++ lib.optionals biryani_services.pipewire.enable [
                                (luaRepeatingExecBind "SUPER + F7" "wpctl set-volume '@DEFAULT_AUDIO_SINK@' '1%-'")
                                (luaRepeatingExecBind "XF86AudioLowerVolume" "wpctl set-volume '@DEFAULT_AUDIO_SINK@' '1%-'")
                                (luaRepeatingExecBind "SUPER + F8" "wpctl set-volume '@DEFAULT_AUDIO_SINK@' '1%+'")
                                (luaRepeatingExecBind "XF86AudioRaiseVolume" "wpctl set-volume '@DEFAULT_AUDIO_SINK@' '1%+'")
                            ]
                            ++ lib.optionals biryani_hw.pulseaudio.enable [
                                (luaRepeatingExecBind "SUPER + F7" "pactl set-sink-volume '@DEFAULT_SINK@' '-1%'")
                                (luaRepeatingExecBind "XF86AudioLowerVolume" "pactl set-sink-volume '@DEFAULT_SINK@' '-1%'")
                                (luaRepeatingExecBind "SUPER + F8" "pactl set-sink-volume '@DEFAULT_SINK@' '+1%'")
                                (luaRepeatingExecBind "XF86AudioRaiseVolume" "pactl set-sink-volume '@DEFAULT_SINK@' '+1%'")
                            ]
                        )}

                        hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
                        hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
                        hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(${
                            luaString screenlocks_meta."${screenlock}".cmd
                        }), { locked = true })

                        ${lib.concatStringsSep "\n" [
                            (luaWindowRule [
                                ''match = { class = "org.telegram.desktop" }''
                                ''workspace = "9"''
                            ])
                            (luaWindowRule [
                                ''match = { class = "teams-for-linux" }''
                                ''workspace = "10"''
                            ])
                            (luaWindowRule [
                                ''match = { class = "org.telegram.desktop", title = "^(Media viewer)$" }''
                                ''workspace = "unset"''
                            ])
                            (luaWindowRule [
                                ''match = { title = "Bitwarden" }''
                                "float = true"
                            ])
                            (luaWindowRule [
                                ''match = { class = "Beeper" }''
                                ''workspace = "10"''
                            ])
                            (luaWindowRule [
                                ''match = { class = "dragon-drop" }''
                                "pin = true"
                            ])
                            (luaWindowRule [
                                ''match = { class = "^(ueberzug.*)$" }''
                                "float = true"
                            ])
                            (luaWindowRule [
                                ''match = { class = "^(ueberzug.*)$" }''
                                "no_initial_focus = true"
                            ])
                        ]}

                        hl.define_submap("screenshot", function()
                          hl.bind("Escape", hl.dsp.submap("reset"))
                          hl.bind("H", hl.dsp.exec_cmd(${luaString "${pkgs.libnotify}/bin/notify-send -- \"Screenshot Keybinds\" \"${ss_group_help}\""}))
                          hl.bind("R", function()
                            hl.dispatch(hl.dsp.submap("reset"))
                            hl.exec_cmd(${luaString ss_tools_meta."${ss_tool}".cmd.region})
                          end)
                          hl.bind("F", function()
                            hl.dispatch(hl.dsp.submap("reset"))
                            hl.exec_cmd(${luaString ss_tools_meta."${ss_tool}".cmd.fullscreen})
                          end)
                        end)
                        hl.bind("SUPER + SHIFT + S", hl.dsp.submap("screenshot"))
                        ${lib.optionalString config.biryani.programs.notification_daemons.swaync.enable ''
                            hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd(${luaString "${pkgs.swaynotificationcenter}/bin/swaync-client -t"}))
                        ''}

                        hl.define_submap("mouse", function()
                          hl.bind("Escape", hl.dsp.submap("reset"))
                          hl.bind("KP_HOME", hl.dsp.exec_cmd(${luaString "${ydotool} mousemove -- -10 -10 && sleep 0.1"}), { repeating = true })
                          hl.bind("KP_PRIOR", hl.dsp.exec_cmd(${luaString "${ydotool} mousemove -- 10 -10 && sleep 0.1"}), { repeating = true })
                          hl.bind("KP_END", hl.dsp.exec_cmd(${luaString "${ydotool} mousemove -- -10 10 && sleep 0.1"}), { repeating = true })
                          hl.bind("KP_NEXT", hl.dsp.exec_cmd(${luaString "${ydotool} mousemove -- 10 10 && sleep 0.1"}), { repeating = true })
                          hl.bind("KP_LEFT", hl.dsp.exec_cmd(${luaString "${ydotool} mousemove -- -10 0 && sleep 0.1"}), { repeating = true })
                          hl.bind("KP_RIGHT", hl.dsp.exec_cmd(${luaString "${ydotool} mousemove -- 10 0 && sleep 0.1"}), { repeating = true })
                          hl.bind("KP_UP", hl.dsp.exec_cmd(${luaString "${ydotool} mousemove -- 0 -10 && sleep 0.1"}), { repeating = true })
                          hl.bind("KP_DOWN", hl.dsp.exec_cmd(${luaString "${ydotool} mousemove -- 0 10 && sleep 0.1"}), { repeating = true })
                          hl.bind("KP_BEGIN", hl.dsp.exec_cmd(${luaString "${ydotool} click C0"}))
                          hl.bind("KP_DIVIDE", hl.dsp.exec_cmd(${luaString "${ydotool} click 0x40"}))
                          hl.bind("KP_MULTIPLY", hl.dsp.exec_cmd(${luaString "${ydotool} click 0x42 0x82"}))
                          hl.bind("KP_SUBTRACT", hl.dsp.exec_cmd(${luaString "${ydotool} click 0x41 0x81"}))
                          hl.bind("KP_INSERT", hl.dsp.exec_cmd(${luaString "sh -c 'if [ \"$(cat /tmp/mouse_state)\" = \"40\" ]; then echo \"80\" > /tmp/mouse_state && ${ydotool} click 0x80; else echo \"40\" > /tmp/mouse_state && ${ydotool} click 0x40; fi'"}))
                          hl.bind("KP_Enter", hl.dsp.exec_cmd(${luaString "sudo pkill ${ydotool}d"}))
                          hl.bind("KP_Add", hl.dsp.exec_cmd(${luaString "sudo ${ydotool}d --socket-perm=0666 --socket-path=/run/user/1000/.ydotool_socket"}))
                        end)
                        hl.bind("SUPER + SHIFT + M", hl.dsp.submap("mouse"))
                    '';
            };

            services.hyprpaper = {
                enable = true;
                package = hyprpaper_pkg;
                settings = {
                    preload = [ biryani_theming.wallpaper ];
                    ipc = "off";
                    splash = false;
                    wallpaper = [
                        {
                            monitor = "";
                            path = biryani_theming.wallpaper;
                        }
                    ];
                };
            };

            home.packages = [ pkgs.networkmanagerapplet ];
        };
}
