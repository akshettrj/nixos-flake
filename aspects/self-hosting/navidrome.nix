{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.services.self_hosted.navidrome =
        let
            jsonFormat = pkgs.formats.json { };
        in
        {
            enable = lib.mkEnableOption "Navidrome";

            frontend_hostname = lib.mkOption {
                type = lib.types.str;
                description = "Frontend hostname advertised by Navidrome.";
            };

            frontend_scheme = lib.mkOption {
                type = lib.types.enum [
                    "http"
                    "https"
                ];
                description = "Public URL scheme used for Navidrome links.";
            };

            port = lib.mkOption {
                type = lib.types.port;
                description = "Local Navidrome port.";
            };

            settings = lib.mkOption {
                type = jsonFormat.type;
                description = "Navidrome settings rendered as JSON-compatible configuration.";
            };

            nginx = {
                enable = lib.mkOption {
                    type = lib.types.bool;
                    description = "Enable an Nginx virtual host for Navidrome.";
                };

                hostname = lib.mkOption {
                    type = lib.types.str;
                    description = "Public hostname for the Navidrome Nginx virtual host.";
                };

                enable_ssl = lib.mkOption {
                    type = lib.types.bool;
                    description = "Force SSL for the Navidrome Nginx virtual host.";
                };
            };
        };

    config =
        let
            biryani_navidrome = config.biryani.services.self_hosted.navidrome;
            biryani_nginx = config.biryani.services.nginx;
            biryani_user = config.biryani.user;
        in
        lib.mkIf biryani_navidrome.enable {
            assertions = [
                {
                    assertion = if biryani_navidrome.nginx.enable then biryani_nginx.enable else true;
                    message = "Navidrome's nginx is enabled, but global nginx is not";
                }
            ];

            users.users.navidrome.extraGroups = [ "acme" ];
            users.users."${biryani_user.username}".extraGroups = [ "navidrome" ];

            services.navidrome = {
                enable = true;
                settings = biryani_navidrome.settings;
            };

            services.nginx = lib.mkIf biryani_navidrome.nginx.enable {
                virtualHosts."${biryani_navidrome.nginx.hostname}" =
                    let
                        certDir = config.security.acme.certs."${biryani_navidrome.nginx.hostname}".directory;
                    in
                    {
                        forceSSL = biryani_navidrome.nginx.enable_ssl;
                        sslCertificate = "${certDir}/cert.pem";
                        sslCertificateKey = "${certDir}/key.pem";
                        locations."/" = {
                            proxyPass = "http://localhost:${toString biryani_navidrome.settings.Port}";
                            extraConfig = ''
                                proxy_http_version 1.1;
                                proxy_set_header Upgrade $http_upgrade;
                                proxy_set_header Connection 'upgrade';
                                proxy_set_header Host $host;
                                proxy_cache_bypass $http_upgrade;
                            '';
                        };
                    };
            };

            biryani.programs.extra_utilities.ffmpeg.enable = lib.mkForce true;
        };
}
