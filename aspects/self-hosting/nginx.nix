{
    config,
    lib,
    pkgs_unstable_small,
    ...
}:
let
    biryani_nginx = config.biryani.services.nginx;
in
{
    options.biryani.services.nginx = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable the shared Nginx reverse proxy service.";
        };

        package = lib.mkOption {
            type = lib.types.package;
            default = pkgs_unstable_small.nginxStable;
            defaultText = "pkgs_unstable_small.nginxStable";
            description = ''
                Nginx package to run. Defaults to the nixos-unstable-small build,
                which lands security fixes ahead of nixos-unstable: currently the
                "NGINX2Root" batch published 2026-11-18 (CVE-2026-123007,
                CVE-2026-123633, CVE-2026-123634, CVE-2026-121810,
                CVE-2026-113425), fixed in nginx 1.30.7.
            '';
        };
    };

    config = lib.mkMerge [
        # Deliberately keyed on `services.nginx.enable` rather than on the aspect
        # toggle: other modules start nginx on their own (raspi gets it from the
        # Nextcloud module), and those hosts need the same patched build.
        (lib.mkIf config.services.nginx.enable {
            services.nginx.package = lib.mkDefault biryani_nginx.package;
        })

        (lib.mkIf biryani_nginx.enable {
            services.nginx = {
                enable = true;
                recommendedTlsSettings = false;
                recommendedGzipSettings = false;
                recommendedOptimisation = false;
                recommendedProxySettings = false;
                recommendedBrotliSettings = false;
            };

            users.users.nginx.extraGroups = [ "acme" ];
        })
    ];
}
