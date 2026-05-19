{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.services.self_hosted.vikunja =
        let
            yamlFormat = pkgs.formats.yaml { };
        in
        {
            enable = lib.mkEnableOption "Vikunja";

            frontend_hostname = lib.mkOption {
                type = lib.types.str;
                description = "Frontend hostname advertised by Vikunja.";
            };

            frontend_scheme = lib.mkOption {
                type = lib.types.enum [
                    "http"
                    "https"
                ];
                description = "Public URL scheme used for Vikunja links.";
            };

            port = lib.mkOption {
                type = lib.types.port;
                description = "Local Vikunja port.";
            };

            settings = lib.mkOption {
                type = yamlFormat.type;
                description = "Vikunja settings rendered as YAML-compatible configuration.";
            };

            nginx = {
                enable = lib.mkOption {
                    type = lib.types.bool;
                    description = "Enable an Nginx virtual host for Vikunja.";
                };

                hostname = lib.mkOption {
                    type = lib.types.str;
                    description = "Public hostname for the Vikunja Nginx virtual host.";
                };

                enable_ssl = lib.mkOption {
                    type = lib.types.bool;
                    description = "Force SSL for the Vikunja Nginx virtual host.";
                };
            };
        };

    config =
        let
            biryani_nginx = config.biryani.services.nginx;
            biryani_vikunja = config.biryani.services.self_hosted.vikunja;
        in
        lib.mkIf biryani_vikunja.enable {
            assertions = [
                {
                    assertion = if biryani_vikunja.nginx.enable then biryani_nginx.enable else true;
                    message = "Vikunja's nginx is enabled, but global nginx is not";
                }
            ];

            services.vikunja = {
                enable = true;
                frontendHostname = biryani_vikunja.frontend_hostname;
                frontendScheme = biryani_vikunja.frontend_scheme;
                port = biryani_vikunja.port;
                settings = biryani_vikunja.settings;
            };

            services.nginx = lib.mkIf biryani_vikunja.nginx.enable {
                virtualHosts."${biryani_vikunja.nginx.hostname}" =
                    let
                        certDir = config.security.acme.certs."${biryani_vikunja.frontend_hostname}".directory;
                    in
                    {
                        forceSSL = biryani_vikunja.nginx.enable_ssl;
                        sslCertificate = "${certDir}/cert.pem";
                        sslCertificateKey = "${certDir}/key.pem";
                        locations."/" = {
                            proxyPass = "http://localhost:${toString biryani_vikunja.port}";
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
        };
}
