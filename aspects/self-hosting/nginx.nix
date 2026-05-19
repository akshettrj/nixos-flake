{ config, lib, ... }:
{
    options.biryani.services.nginx.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable the shared Nginx reverse proxy service.";
    };

    config =
        let
            biryani_nginx = config.biryani.services.nginx;
        in
        lib.mkIf biryani_nginx.enable {
            services.nginx = {
                enable = true;
                recommendedTlsSettings = false;
                recommendedGzipSettings = false;
                recommendedOptimisation = false;
                recommendedProxySettings = false;
                recommendedBrotliSettings = false;
            };

            users.users.nginx.extraGroups = [ "acme" ];
        };
}
