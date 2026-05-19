{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    options =
        let
            inherit (lib) mkOption mkEnableOption types;

            known_browsers = lib.attrNames (import ./metadata/programs/browsers.nix { inherit pkgs; });
            known_clipboard_managers = lib.attrNames (
                import ./metadata/programs/clipboard_managers.nix { inherit pkgs; }
            );
            known_desktop_environments = lib.attrNames (
                import ./metadata/programs/desktop_environments.nix { inherit config inputs pkgs; }
            );
            known_editors = lib.attrNames (
                import ./metadata/programs/editors.nix { inherit config inputs pkgs; }
            );
            known_file_explorers = lib.attrNames (
                import ./metadata/programs/file_explorers.nix { inherit pkgs; }
            );
            known_launchers = lib.attrNames (import ./metadata/programs/launchers.nix { inherit pkgs; });
            known_shells = lib.attrNames (import ./metadata/programs/shells.nix { inherit pkgs; });
            known_screenlocks = lib.attrNames (
                import ./metadata/programs/screenlocks.nix { inherit config inputs pkgs; }
            );
            known_screenshot_tools = lib.attrNames (
                import ./metadata/programs/screenshot_tools.nix { inherit pkgs; }
            );
            known_terminals = lib.attrNames (
                import ./metadata/programs/terminals.nix { inherit config inputs pkgs; }
            );

            font_type = lib.types.submodule {
                options = {
                    name = mkOption { type = types.str; };
                    size = mkOption { type = types.ints.unsigned; };
                };
            };

            monitor_type = lib.types.submodule {
                options = {
                    enabled = mkOption { type = types.bool; };
                    name = mkOption { type = types.str; };
                    width = mkOption { type = types.int; };
                    height = mkOption { type = types.int; };
                    refresh_rate = mkOption { type = types.int; };
                    x = mkOption { type = types.int; };
                    y = mkOption { type = types.int; };
                    additional_settings = mkOption { type = types.str; };
                    workspaces = mkOption { type = types.listOf (types.int); };
                };
            };

            watgbridge_instance_type = lib.types.submodule {
                options = {
                    enabled = mkOption { type = types.bool; };
                    package = mkOption {
                        type = types.package;
                        default = inputs.watgbridge.packages."${pkgs.stdenv.hostPlatform.system}".default;
                    };
                    instance_name = mkOption { type = types.str; };
                    config_file = mkOption { type = types.nullOr types.str; };
                    user = mkOption { type = types.str; };
                    group = mkOption { type = types.str; };
                    max_runtime = mkOption { type = types.nullOr types.str; };
                    working_directory = mkOption { type = types.nullOr types.str; };
                    after = mkOption { type = types.listOf types.str; };
                    requires = mkOption { type = types.listOf types.str; };
                };
            };

            json_format = pkgs.formats.json { };
            yaml_format = pkgs.formats.yaml { };
        in
        {
            biryani = {
                # Home Manager options that have not been moved to aspect modules yet.
                services = {
                    xdg_portal.enable = mkOption { type = types.bool; };
                    self_hosted = {
                        mediawiki = {
                            enable = mkEnableOption "Mediawiki";
                        };
                    };
                };

                # Appearance
                theming = {
                    qt = mkOption { type = types.bool; };
                    cursor = {
                        package = mkOption { type = types.package; };
                        name = mkOption { type = types.str; };
                        size = mkOption { type = types.ints.unsigned; };
                    };
                    minimum_brightness = mkOption { type = types.ints.unsigned; };
                    wallpaper = mkOption { type = types.path; };
                };

                dev = {
                    git = {
                        enable = mkOption { type = types.bool; };
                        user = {
                            name = mkOption { type = types.str; };
                            email = mkOption { type = types.str; };
                        };
                        delta.enable = mkOption { type = types.bool; };
                        default_branch = mkOption { type = types.str; };
                    };
                    direnv.enable = mkOption { type = types.bool; };
                    cachix.enable = mkOption { type = types.bool; };
                };

                programs = {
                    media = {
                        enable = mkOption { type = types.bool; };
                        services = {
                            mpris.enable = mkOption { type = types.bool; };
                        };
                        audio = {
                            mpd = {
                                enable = mkOption { type = types.bool; };
                                ncmpcpp.enable = mkOption { type = types.bool; };
                            };
                        };
                        video = {
                            mpv.enable = mkOption { type = types.bool; };
                            vlc.enable = mkOption { type = types.bool; };
                            stremio.enable = mkOption { type = types.bool; };
                            jellyfin.enable = mkOption { type = types.bool; };
                        };
                        picture = {
                            feh.enable = mkOption { type = types.bool; };
                            sxiv.enable = mkOption { type = types.bool; };
                        };
                        documents = {
                            zathura = {
                                enable = mkOption { type = types.bool; };
                                useMupdf = mkOption { type = types.bool; };
                            };
                            sioyek = {
                                enable = mkOption { type = types.bool; };
                            };
                        };
                    };
                    ai = {
                        enable = mkOption {
                            type = types.bool;
                            default = false;
                        };
                        mcpServers = mkOption { type = json_format.type; };
                        skills = mkOption { type = lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path); };
                        cursor = {
                            enable = mkOption { type = types.bool; };
                        };
                        gemini = {
                            enable = mkOption { type = types.bool; };
                            mcpServers = mkOption { type = json_format.type; };
                        };
                        codex = {
                            enable = mkOption { type = types.bool; };
                            mcpServers = mkOption { type = json_format.type; };
                        };
                        ollama = {
                            enable = mkOption { type = types.bool; };
                            acceleration = mkOption {
                                type = types.nullOr (
                                    types.enum [
                                        false
                                        "rocm"
                                        "cuda"
                                    ]
                                );
                            };
                        };
                    };
                    social_media = {
                        telegram.enable = mkEnableOption "telegram";
                        discord.enable = mkEnableOption "discord";
                        beeper.enable = mkEnableOption "beeper";
                        slack.enable = mkEnableOption "slack";
                        teams.enable = mkEnableOption "teams";
                        zulip.enable = mkEnableOption "zulip";
                    };
                    editors = {
                        main = mkOption {
                            type = types.enum known_editors;
                            example = "neovim";
                        };
                        backup = mkOption {
                            type = types.enum known_editors;
                            example = "helix";
                        };
                        zeditor = {
                            enable = mkOption { type = types.bool; };
                        };
                    };
                    terminals = {
                        enable = mkOption { type = types.bool; };
                        main = mkOption { type = types.enum known_terminals; };
                        backup = mkOption { type = types.enum known_terminals; };
                        wezterm = {
                            enable = mkOption { type = types.bool; };
                            font_size = mkOption { type = types.number; };
                            use_official_package = mkOption { type = types.bool; };
                            enable_wayland = mkOption { type = types.bool; };
                        };
                        alacritty = {
                            enable = mkOption { type = types.bool; };
                            font_size = mkOption { type = types.number; };
                        };
                        ghostty = {
                            enable = mkOption { type = types.bool; };
                            use_official_package = mkOption { type = types.bool; };
                            background_opacity = mkOption { type = types.number; };
                            background_blur = mkOption { type = types.bool; };
                        };
                    };
                    browsers = {
                        enable = mkOption { type = types.bool; };
                        main = mkOption { type = types.enum known_browsers; };
                        brave = {
                            enable = mkOption { type = types.bool; };
                            cmd_args = mkOption { type = types.listOf (types.str); };
                        };
                        firefox.enable = mkOption { type = types.bool; };
                        chromium = {
                            enable = mkOption { type = types.bool; };
                            cmd_args = mkOption { type = types.listOf (types.str); };
                            extensions = mkOption { type = types.anything; };
                        };
                        chrome = {
                            enable = mkOption { type = types.bool; };
                            cmd_args = mkOption { type = types.listOf (types.str); };
                            extensions = mkOption { type = types.anything; };
                        };
                    };
                    file_explorers = {
                        main = mkOption { type = types.enum known_file_explorers; };
                        backup = mkOption { type = types.enum known_file_explorers; };
                        lf.enable = mkOption { type = types.bool; };
                        yazi.enable = mkOption { type = types.bool; };
                    };
                    launchers = {
                        enable = mkOption { type = types.bool; };
                        bemenu = {
                            enable = mkOption { type = types.bool; };
                            font_size = mkOption { type = types.ints.unsigned; };
                        };
                    };
                    screenshot_tools = {
                        enable = mkOption { type = types.bool; };
                        flameshot.enable = mkOption { type = types.bool; };
                        wayshot.enable = mkOption { type = types.bool; };
                        shotman.enable = mkOption { type = types.bool; };
                        hyprshot.enable = mkOption { type = types.bool; };
                    };
                    screenlocks = {
                        enable = mkOption { type = types.bool; };
                        hyprlock = {
                            background_image = mkOption { type = types.path; };
                        };
                    };
                    clipboard_managers = {
                        enable = mkOption { type = types.bool; };
                        copyq.enable = mkOption { type = types.bool; };
                    };
                    notification_daemons = {
                        enable = mkOption { type = types.bool; };
                        dunst = {
                            enable = mkOption { type = types.bool; };
                            font_size = mkOption { type = types.ints.unsigned; };
                        };
                    };
                    bars = {
                        enable = mkOption {
                            type = types.bool;
                            default = false;
                        };
                        waybar = {
                            enable = mkOption { type = types.bool; };
                            use_official_package = mkOption { type = types.bool; };
                            heights = mkOption { type = types.ints.unsigned; };
                            font_size = mkOption { type = types.ints.unsigned; };
                            separator_size = mkOption { type = types.ints.unsigned; };
                            icon_size = mkOption { type = types.ints.unsigned; };
                            tray_spacing = mkOption { type = types.ints.unsigned; };
                            is_laptop = mkOption { type = types.bool; };
                            systemd_target = mkOption { type = types.str; };
                        };
                        quickshell = {
                            enable = mkOption {
                                type = types.bool;
                                default = false;
                            };
                            use_official_package = mkOption { type = types.bool; };
                            # heights = mkOption {type = types.ints.unsigned;};
                            # font_size = mkOption {type = types.ints.unsigned;};
                            # separator_size = mkOption {type = types.ints.unsigned;};
                            # icon_size = mkOption {type = types.ints.unsigned;};
                            # tray_spacing = mkOption {type = types.ints.unsigned;};
                            # is_laptop = mkOption {type = types.bool;};
                            enabled_configs = mkOption { type = types.listOf types.str; };
                            systemd_target = mkOption { type = types.str; };
                        };
                    };
                };

                shells = {
                    aliases = mkOption { type = types.attrsOf (types.str); };
                    nushell.enable = mkOption { type = types.bool; };

                    eza.enable = mkOption { type = types.bool; };
                    starship.enable = mkOption { type = types.bool; };
                    zoxide.enable = mkOption { type = types.bool; };
                };

                desktop_environments = {
                    enable = mkOption { type = types.bool; };
                    defaults = mkOption { type = types.attrsOf (types.enum known_desktop_environments); };
                    wayland.enable = mkOption { type = types.bool; };
                    hyprland = {
                        enable = mkOption { type = types.bool; };
                        use_official_packages = mkOption { type = types.bool; };
                        scroll_factor = mkOption { type = types.number; };
                        screenlock = mkOption { type = types.enum known_screenlocks; };
                        launcher = mkOption { type = types.enum known_launchers; };
                        screenshot_tool = mkOption { type = types.enum known_screenshot_tools; };
                        clipboard_manager = mkOption { type = types.enum known_clipboard_managers; };
                        monitors = mkOption { type = types.listOf monitor_type; };
                    };
                };
            };
        };
}
