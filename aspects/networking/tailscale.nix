{ config, lib, ... }:
{
    options.biryani.services.tailscale.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable Tailscale with routing support.";
    };

    config =
        let
            biryani_services = config.biryani.services;
        in
        lib.mkIf biryani_services.tailscale.enable {
            services.tailscale = {
                enable = true;
                useRoutingFeatures = "both";
            };
        };
}
