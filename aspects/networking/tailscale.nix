{ config, lib, ... }:
{
    options.biryani.services.tailscale = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Tailscale with routing support.";
        };

        advertise_exit_node = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Tailscale with routing support.";
            default = false;
        };
    };

    config =
        let
            biryani_services = config.biryani.services;
            biryani_user = config.biryani.user;
        in
        lib.mkIf biryani_services.tailscale.enable {
            services.tailscale = {
                enable = true;
                useRoutingFeatures = "both";
                extraSetFlags = [
                    "--operator=${biryani_user.username}"
                ] ++ lib.optionals biryani_services.tailscale.advertise_exit_node [
                    "--advertise-exit-node"
                ];
                extraDaemonFlags = [
                    "--no-logs-no-support"
                ];
            };
        };
}
