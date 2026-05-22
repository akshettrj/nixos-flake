{ config, lib, ... }:
{
    config =
        let
            biryani_notifiers = config.biryani.programs.notification_daemons;
            biryani_theming = config.biryani.theming;
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
                      border: 1px solid #44475a;
                      border-radius: 8px;
                      background: #1e1e2e;
                      color: #cdd6f4;
                    }

                    .notification-row:focus,
                    .notification-row:hover {
                      background: #313244;
                    }

                    .notification-content {
                      padding: 8px;
                    }

                    .close-button {
                      background: #f38ba8;
                      color: #1e1e2e;
                    }
                '';
            };
        };
}
