{ lib, biryani, ... }:
{
    config.biryani = {
        hardware = {
            nvidia.enable = biryani.hardware.nvidia.enable;
            pulseaudio.enable = biryani.hardware.pulseaudio.enable;
        };

        programs = {
            bars = {
                enable = biryani.programs.bars.enable;
                quickshell.enable = biryani.programs.bars.quickshell.enable;
            }
            // lib.optionalAttrs biryani.programs.bars.enable { waybar = biryani.programs.bars.waybar; }
            // lib.optionalAttrs (biryani.programs.bars.enable && biryani.programs.bars.quickshell.enable) {
                quickshell = biryani.programs.bars.quickshell;
            };

            clipboard_managers = biryani.programs.clipboard_managers;
            launchers = biryani.programs.launchers;
            notification_daemons = biryani.programs.notification_daemons;
            screenlocks = biryani.programs.screenlocks;
            screenshot_tools = biryani.programs.screenshot_tools;
        };

        services.pipewire.enable = biryani.services.pipewire.enable;
        system.time_zone = biryani.system.time_zone;

        desktop_environments = {
            enable = biryani.desktop_environments.enable;
        }
        // lib.optionalAttrs biryani.desktop_environments.enable {
            defaults = biryani.desktop_environments.defaults;
            hyprland = biryani.desktop_environments.hyprland;
            wayland = biryani.desktop_environments.wayland;
        };

        theming = {
            fonts = {
                main = {
                    name = biryani.theming.fonts.main.name;
                    size = biryani.theming.fonts.main.size;
                };
                backups = biryani.theming.fonts.backups;
            };
            cursor = biryani.theming.cursor;
            enable = biryani.theming.enable;
            gtk = biryani.theming.gtk;
            minimum_brightness = biryani.theming.minimum_brightness;
            qt = biryani.theming.qt;
            wallpaper = biryani.theming.wallpaper;
        };
    };
}
