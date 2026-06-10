{ lib, ... }: {
    imports = [
        ./quickshell
        ./waybar.nix
    ];

    options.biryani = {
        programs.bars = {
            enable = lib.mkEnableOption "desktop bars.";
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

        hardware.pulseaudio.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Whether Pulseaudio is enabled for bar audio controls.";
        };
        services.pipewire.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Whether Pipewire is enabled for bar audio controls.";
        };
        system.time_zone = lib.mkOption {
            type = lib.types.str;
            description = "Timezone used by bar clock widgets.";
        };
    };
}
