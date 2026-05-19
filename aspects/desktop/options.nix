{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
let
    knownClipboardManagers = lib.attrNames (
        import ../core/metadata/programs/clipboard_managers.nix { inherit pkgs; }
    );
    knownDesktopEnvironments = lib.attrNames (
        import ../core/metadata/programs/desktop_environments.nix { inherit config inputs pkgs; }
    );
    knownLaunchers = lib.attrNames (import ../core/metadata/programs/launchers.nix { inherit pkgs; });
    knownScreenlocks = lib.attrNames (
        import ../core/metadata/programs/screenlocks.nix { inherit config inputs pkgs; }
    );
    knownScreenshotTools = lib.attrNames (
        import ../core/metadata/programs/screenshot_tools.nix { inherit pkgs; }
    );

    monitorType = lib.types.submodule {
        options = {
            enabled = lib.mkOption {
                type = lib.types.bool;
                description = "Whether this monitor is enabled.";
            };
            name = lib.mkOption {
                type = lib.types.str;
                description = "Monitor output name.";
            };
            width = lib.mkOption {
                type = lib.types.int;
                description = "Monitor width in pixels.";
            };
            height = lib.mkOption {
                type = lib.types.int;
                description = "Monitor height in pixels.";
            };
            refresh_rate = lib.mkOption {
                type = lib.types.int;
                description = "Monitor refresh rate.";
            };
            x = lib.mkOption {
                type = lib.types.int;
                description = "Monitor X position.";
            };
            y = lib.mkOption {
                type = lib.types.int;
                description = "Monitor Y position.";
            };
            additional_settings = lib.mkOption {
                type = lib.types.str;
                description = "Extra Hyprland monitor settings.";
            };
            workspaces = lib.mkOption {
                type = lib.types.listOf lib.types.int;
                description = "Workspace numbers assigned to this monitor.";
            };
        };
    };
in
{
    options.biryani = {
        services.xdg_portal.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Home Manager xdg-desktop-portal integration.";
        };

        theming = {
            qt = lib.mkOption {
                type = lib.types.bool;
                description = "Enable Qt theming through Home Manager.";
            };
            cursor = {
                package = lib.mkOption {
                    type = lib.types.package;
                    description = "Cursor theme package.";
                };
                name = lib.mkOption {
                    type = lib.types.str;
                    description = "Cursor theme name.";
                };
                size = lib.mkOption {
                    type = lib.types.ints.unsigned;
                    description = "Cursor size.";
                };
            };
            minimum_brightness = lib.mkOption {
                type = lib.types.ints.unsigned;
                description = "Minimum brightness percentage used by brightness helpers.";
            };
            wallpaper = lib.mkOption {
                type = lib.types.path;
                description = "Wallpaper image used by desktop theming modules.";
            };
        };

        programs = {
            launchers = {
                enable = lib.mkEnableOption "launcher configuration.";
                bemenu = {
                    enable = lib.mkEnableOption "bemenu launcher.";
                    font_size = lib.mkOption {
                        type = lib.types.ints.unsigned;
                        description = "Font size used by bemenu.";
                    };
                };
            };

            screenshot_tools = {
                enable = lib.mkEnableOption "screenshot tools.";
                flameshot.enable = lib.mkEnableOption "Flameshot screenshot tool.";
                wayshot.enable = lib.mkEnableOption "wayshot screenshot tool.";
                shotman.enable = lib.mkEnableOption "shotman screenshot tool.";
                hyprshot.enable = lib.mkEnableOption "hyprshot screenshot tool.";
            };

            screenlocks = {
                enable = lib.mkEnableOption "screenlock configuration.";
                hyprlock.background_image = lib.mkOption {
                    type = lib.types.path;
                    description = "Background image used by Hyprlock.";
                };
            };

            clipboard_managers = {
                enable = lib.mkEnableOption "clipboard manager configuration.";
                copyq.enable = lib.mkEnableOption "CopyQ clipboard manager.";
            };

            notification_daemons = {
                enable = lib.mkEnableOption "notification daemon configuration.";
                dunst = {
                    enable = lib.mkEnableOption "Dunst notification daemon.";
                    font_size = lib.mkOption {
                        type = lib.types.ints.unsigned;
                        description = "Dunst notification font size.";
                    };
                };
            };

            bars = {
                enable = lib.mkEnableOption "desktop bar configuration.";
                waybar = {
                    enable = lib.mkEnableOption "Waybar.";
                    use_official_package = lib.mkOption {
                        type = lib.types.bool;
                        description = "Use Waybar package from the Waybar flake input.";
                    };
                    heights = lib.mkOption {
                        type = lib.types.ints.unsigned;
                        description = "Waybar bar height.";
                    };
                    font_size = lib.mkOption {
                        type = lib.types.ints.unsigned;
                        description = "Waybar font size.";
                    };
                    separator_size = lib.mkOption {
                        type = lib.types.ints.unsigned;
                        description = "Waybar separator font size.";
                    };
                    icon_size = lib.mkOption {
                        type = lib.types.ints.unsigned;
                        description = "Waybar icon size.";
                    };
                    tray_spacing = lib.mkOption {
                        type = lib.types.ints.unsigned;
                        description = "Waybar tray item spacing.";
                    };
                    is_laptop = lib.mkOption {
                        type = lib.types.bool;
                        description = "Whether Waybar should show laptop battery and backlight modules.";
                    };
                    systemd_target = lib.mkOption {
                        type = lib.types.str;
                        description = "Systemd user target for Waybar.";
                    };
                };
                quickshell = {
                    enable = lib.mkEnableOption "Quickshell bars.";
                    use_official_package = lib.mkOption {
                        type = lib.types.bool;
                        description = "Use Quickshell package from the Quickshell flake input.";
                    };
                    enabled_configs = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        description = "Quickshell config names to start as user services.";
                    };
                    systemd_target = lib.mkOption {
                        type = lib.types.str;
                        description = "Systemd user target for Quickshell services.";
                    };
                };
            };
        };

        desktop_environments = {
            enable = lib.mkEnableOption "desktop environment configuration.";
            defaults = lib.mkOption {
                type = lib.types.attrsOf (lib.types.enum knownDesktopEnvironments);
                description = "TTY to desktop environment mapping used by login shell autostart.";
            };
            wayland.enable = lib.mkEnableOption "Wayland desktop session support.";
            hyprland = {
                enable = lib.mkEnableOption "Hyprland.";
                use_official_packages = lib.mkOption {
                    type = lib.types.bool;
                    description = "Use Hyprland packages from flake inputs.";
                };
                scroll_factor = lib.mkOption {
                    type = lib.types.number;
                    description = "Hyprland touchpad scroll factor.";
                };
                screenlock = lib.mkOption {
                    type = lib.types.enum knownScreenlocks;
                    description = "Screenlock backend used by Hyprland keybindings.";
                };
                launcher = lib.mkOption {
                    type = lib.types.enum knownLaunchers;
                    description = "Launcher backend used by Hyprland keybindings.";
                };
                screenshot_tool = lib.mkOption {
                    type = lib.types.enum knownScreenshotTools;
                    description = "Screenshot tool used by Hyprland keybindings.";
                };
                clipboard_manager = lib.mkOption {
                    type = lib.types.enum knownClipboardManagers;
                    description = "Clipboard manager used by Hyprland startup.";
                };
                monitors = lib.mkOption {
                    type = lib.types.listOf monitorType;
                    description = "Hyprland monitor layout.";
                };
            };
        };
    };
}
