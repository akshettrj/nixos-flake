{ config, lib, ... }: {
    options.biryani.services.self_hosted.audiobookshelf = {
        enable = lib.mkEnableOption "Audiobookshelf";

        port = lib.mkOption {
            type = lib.types.port;
            description = "Local port used by Audiobookshelf.";
        };

        nginx = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable an Nginx virtual host for Audiobookshelf.";
            };

            hostname = lib.mkOption {
                type = lib.types.str;
                description = "Public hostname for Audiobookshelf.";
            };

            enable_ssl = lib.mkOption {
                type = lib.types.bool;
                description = "Force SSL for the Audiobookshelf Nginx virtual host.";
            };
        };
    };

    config =
        let
            biryani_audiobookshelf = config.biryani.services.self_hosted.audiobookshelf;
            biryani_nginx = config.biryani.services.nginx;
            biryani_user = config.biryani.user;
        in
        lib.mkIf biryani_audiobookshelf.enable {
            assertions = [
                {
                    assertion = if biryani_audiobookshelf.nginx.enable then biryani_nginx.enable else true;
                    message = "Audiobookshelf's nginx is enabled, but global nginx is not";
                }
            ];

            users.users.audiobookshelf.extraGroups = [ "acme" ];
            users.users."${biryani_user.username}".extraGroups = [ "audiobookshelf" ];

            services.audiobookshelf = {
                enable = true;
                host = "127.0.0.1";
                port = biryani_audiobookshelf.port;
            };

            services.nginx = lib.mkIf biryani_audiobookshelf.nginx.enable {
                virtualHosts."${biryani_audiobookshelf.nginx.hostname}" =
                    let
                        certDir = config.security.acme.certs."${biryani_audiobookshelf.nginx.hostname}".directory;
                    in
                    {
                        forceSSL = biryani_audiobookshelf.nginx.enable_ssl;
                        sslCertificate = "${certDir}/cert.pem";
                        sslCertificateKey = "${certDir}/key.pem";
                        locations."/" = {
                            proxyPass = "http://localhost:${toString biryani_audiobookshelf.port}";
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

            # biryani.programs.extra_utilities.ffmpeg.enable = lib.mkForce true;
        };
}
