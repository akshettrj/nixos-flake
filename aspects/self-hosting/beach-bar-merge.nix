{
    config,
    inputs,
    lib,
    ...
}:
{
    imports = [ inputs.merge_game.nixosModules.beach-bar-merge ];

    options.biryani.services.self_hosted.beach_bar_merge = {
        enable = lib.mkEnableOption "Beach Bar Merge, a drink merge game";

        port = lib.mkOption {
            type = lib.types.port;
            description = "Local Beach Bar Merge server port.";
        };

        nginx = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable an Nginx virtual host for Beach Bar Merge.";
            };

            hostname = lib.mkOption {
                type = lib.types.str;
                description = "Public hostname for the Beach Bar Merge Nginx virtual host.";
            };

            enable_ssl = lib.mkOption {
                type = lib.types.bool;
                description = "Force SSL for the Beach Bar Merge Nginx virtual host.";
            };
        };
    };

    config =
        let
            biryani_merge = config.biryani.services.self_hosted.beach_bar_merge;
            biryani_nginx = config.biryani.services.nginx;
        in
        lib.mkIf biryani_merge.enable {
            assertions = [
                {
                    assertion = if biryani_merge.nginx.enable then biryani_nginx.enable else true;
                    message = "Beach Bar Merge's nginx is enabled, but global nginx is not";
                }
            ];

            services.beach-bar-merge = {
                enable = true;
                port = biryani_merge.port;
                address = "127.0.0.1";
                openFirewall = false;

                # The upstream module's own `nginx.enable` turns on nginx's
                # `recommended*Settings`, which this flake deliberately keeps off
                # (see aspects/self-hosting/nginx.nix), and issues its certificate
                # over HTTP-01. The virtual host below is written here instead, so
                # it reuses the shared Nginx and the DNS-01 certificate.
                nginx.enable = false;

                # Both default to the upstream `nginx.enable` above, so they have
                # to be set explicitly now that the proxy lives outside the module.
                # The vhost below terminates TLS and overwrites X-Forwarded-For, so
                # the header can be trusted for rate limiting.
                hsts = biryani_merge.nginx.enable && biryani_merge.nginx.enable_ssl;
                trustProxy = biryani_merge.nginx.enable;
            };

            services.nginx = lib.mkIf biryani_merge.nginx.enable {
                virtualHosts."${biryani_merge.nginx.hostname}" =
                    let
                        certDir = config.security.acme.certs."${biryani_merge.nginx.hostname}".directory;
                    in
                    {
                        forceSSL = biryani_merge.nginx.enable_ssl;
                        sslCertificate = "${certDir}/cert.pem";
                        sslCertificateKey = "${certDir}/key.pem";
                        locations."/" = {
                            proxyPass = "http://localhost:${toString biryani_merge.port}";
                            extraConfig = ''
                                proxy_http_version 1.1;
                                proxy_set_header Upgrade $http_upgrade;
                                proxy_set_header Connection 'upgrade';
                                proxy_set_header Host $host;
                                proxy_set_header X-Real-IP $remote_addr;
                                proxy_set_header X-Forwarded-For $remote_addr;
                                proxy_set_header X-Forwarded-Proto $scheme;
                                proxy_cache_bypass $http_upgrade;
                            '';
                        };
                    };
            };
        };
}
