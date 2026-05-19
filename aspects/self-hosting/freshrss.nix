{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.services.self_hosted.freshrss = {
        enable = lib.mkEnableOption "FreshRSS";

        hostname = lib.mkOption {
            type = lib.types.str;
            description = "Public hostname for FreshRSS.";
        };

        base_url = lib.mkOption {
            type = lib.types.str;
            description = "Public base URL for FreshRSS.";
        };
    };

    config =
        let
            biryani_freshrss = config.biryani.services.self_hosted.freshrss;
            biryani_user = config.biryani.user;
        in
        lib.mkIf biryani_freshrss.enable {
            users.users.freshrss.extraGroups = [
                "acme"
                "nginx"
            ];
            users.users."${biryani_user.username}".extraGroups = [ "freshrss" ];

            services.freshrss = {
                enable = true;
                package = pkgs.freshrss;
                extensions = with pkgs.freshrss-extensions; [
                    auto-ttl
                    reading-time
                    reddit-image
                    title-wrap
                    youtube
                ];
                baseUrl = biryani_freshrss.base_url;
                defaultUser = biryani_user.username;
                database.type = "sqlite";
                webserver = "nginx";
                virtualHost = biryani_freshrss.hostname;
                passwordFile = "/var/lib/default_password";
            };

            services.nginx.virtualHosts."${biryani_freshrss.hostname}" =
                let
                    certDir = config.security.acme.certs."${biryani_freshrss.hostname}".directory;
                in
                {
                    forceSSL = true;
                    sslCertificate = "${certDir}/cert.pem";
                    sslCertificateKey = "${certDir}/key.pem";
                };
        };
}
