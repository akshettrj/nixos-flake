{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.services.self_hosted.glance =
        let
            yamlFormat = pkgs.formats.yaml { };
        in
        {
            enable = lib.mkEnableOption "Glance dashboard";

            hostname = lib.mkOption {
                type = lib.types.str;
                description = "Public hostname for Glance.";
            };

            port = lib.mkOption {
                type = lib.types.port;
                description = "Local Glance server port.";
            };

            pages = lib.mkOption {
                type = yamlFormat.type;
                description = "Glance page configuration rendered as YAML-compatible data.";
            };
        };

    config =
        let
            biryani_glance = config.biryani.services.self_hosted.glance;
        in
        lib.mkIf biryani_glance.enable {
            services.glance = {
                enable = true;
                package = pkgs.glance;
                openFirewall = false;
                settings = {
                    theme = {
                        background-color = "50 1 6";
                        primary-color = "24 97 58";
                        negative-color = "209 88 54";
                    };
                    auth = { };
                    server = {
                        host = "127.0.0.1";
                        port = biryani_glance.port;
                        proxied = true;
                    };
                    pages = biryani_glance.pages;
                };
            };

            services.nginx.virtualHosts."${biryani_glance.hostname}" =
                let
                    certDir = config.security.acme.certs."${biryani_glance.hostname}".directory;
                in
                {
                    forceSSL = true;
                    sslCertificate = "${certDir}/cert.pem";
                    sslCertificateKey = "${certDir}/key.pem";
                    locations."/" = {
                        proxyPass = "http://localhost:${toString biryani_glance.port}";
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
}
