{ config, lib, ... }:
{
    config =
        let
            biryani_notifiers = config.biryani.programs.notification_daemons;
            biryani_theming = config.biryani.theming;
            palette =
                if biryani_theming.matugen.integrations.swaync.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;
        in
        lib.mkIf (biryani_notifiers.enable && biryani_notifiers.swaync.enable) {
            services.swaync = {
                enable = true;

                settings = {
                    positionX = "right";
                    positionY = "top";
                    layer = "overlay";
                    control-center-layer = "top";
                    layer-shell = true;
                    cssPriority = "application";
                    control-center-margin-top = 8;
                    control-center-margin-bottom = 8;
                    control-center-margin-right = 8;
                    control-center-margin-left = 8;
                    notification-2fa-action = true;
                    notification-inline-replies = true;
                    notification-icon-size = 48;
                    notification-body-image-height = 160;
                    notification-body-image-width = 240;
                    timeout = 8;
                    timeout-low = 4;
                    timeout-critical = 0;
                };

                style = ''
                    * {
                      font-family: "${biryani_theming.fonts.main.name}";
                      font-size: 13px;
                    }

                    .notification,
                    .control-center {
                      border: 1px solid ${palette.outline};
                      border-radius: 8px;
                      background: ${palette.surface_container};
                      color: ${palette.on_surface};
                    }

                    .notification-row:focus,
                    .notification-row:hover {
                      background: ${palette.surface_container_high};
                    }

                    .notification-content {
                      padding: 8px;
                    }

                    .close-button {
                      background: ${palette.error};
                      color: ${palette.on_error};
                    }
                '';
            };
        };
}
