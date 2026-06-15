{ lib, ... }:
let
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
    imports = [
        ./both
        ./wayland
        ./x11
    ];

    options.biryani = {
        desktop_environments = {
            enable = lib.mkEnableOption "desktop environment Home Manager configuration.";
            defaults = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                description = "TTY to desktop environment mapping used by login shell autostart.";
            };
            wayland.enable = lib.mkEnableOption "Wayland desktop session support.";
            hyprland = {
                enable = lib.mkEnableOption "Hyprland Home Manager configuration.";
                use_official_packages = lib.mkOption {
                    type = lib.types.bool;
                    description = "Use Hyprland packages from flake inputs.";
                };
                scroll_factor = lib.mkOption {
                    type = lib.types.number;
                    description = "Hyprland touchpad scroll factor.";
                };
                screenlock = lib.mkOption {
                    type = lib.types.str;
                    description = "Screenlock backend used by Hyprland keybindings.";
                };
                launcher = lib.mkOption {
                    type = lib.types.str;
                    description = "Launcher backend used by Hyprland keybindings.";
                };
                screenshot_tool = lib.mkOption {
                    type = lib.types.str;
                    description = "Screenshot tool used by Hyprland keybindings.";
                };
                clipboard_manager = lib.mkOption {
                    type = lib.types.str;
                    description = "Clipboard manager used by Hyprland startup.";
                };
                monitors = lib.mkOption {
                    type = lib.types.listOf monitorType;
                    description = "Hyprland monitor layout.";
                };
            };
        };

        hardware.nvidia = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Whether Nvidia-specific Wayland environment variables should be enabled.";
            };
            prime.enable = lib.mkOption {
                type = lib.types.bool;
                description = "Whether the host uses NVIDIA PRIME offload (Intel iGPU is primary).";
            };
        };
    };
}
