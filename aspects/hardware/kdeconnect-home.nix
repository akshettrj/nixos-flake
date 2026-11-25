{ config, lib, ... }: {
    imports = [ ./kdeconnect-options.nix ];

    config =
        let
            biryani_kdeconnect = config.biryani.hardware.kdeconnect;
            remote_input = biryani_kdeconnect.remote_input;
        in
        lib.mkIf biryani_kdeconnect.enable (
            lib.mkMerge [
                {
                    services.kdeconnect = {
                        enable = true;
                        package = biryani_kdeconnect.package;
                        indicator = biryani_kdeconnect.indicator;
                    };
                }
                (lib.mkIf (remote_input.enable && config.wayland.windowManager.hyprland.enable) {
                    xdg.portal = {
                        extraPortals = [ remote_input.portal_package ];
                        # A user hyprland-portals.conf replaces the one Hyprland
                        # ships, so restate its default (overridable by the xdg
                        # aspect) and route only RemoteDesktop elsewhere.
                        config.hyprland = {
                            default = lib.mkDefault [
                                "hyprland"
                                "gtk"
                            ];
                            "org.freedesktop.impl.portal.RemoteDesktop" = [ remote_input.portal_name ];
                        };
                    };
                })
            ]
        );
}
