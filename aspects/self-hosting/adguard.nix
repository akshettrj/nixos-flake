{ config, lib, ... }:
{
    options.biryani.services.self_hosted.adguard = {
        enable = lib.mkEnableOption "AdGuard Home";

        open_firewall = lib.mkOption {
            type = lib.types.bool;
            description = "Open firewall ports used by AdGuard DNS.";
        };

        port = lib.mkOption {
            type = lib.types.port;
            description = "HTTP admin port for AdGuard Home.";
        };

        nginx = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable an Nginx virtual host for AdGuard Home.";
            };

            hostname = lib.mkOption {
                type = lib.types.str;
                description = "Public hostname for the AdGuard Home Nginx virtual host.";
            };

            enable_ssl = lib.mkOption {
                type = lib.types.bool;
                description = "Force SSL for the AdGuard Home Nginx virtual host.";
            };
        };
    };

    config =
        let
            biryani_adguard = config.biryani.services.self_hosted.adguard;
        in
        lib.mkIf biryani_adguard.enable {
            services.adguardhome = {
                enable = true;
                mutableSettings = true;
                openFirewall = biryani_adguard.open_firewall;
                port = biryani_adguard.port;
            };

            services.nginx = lib.mkIf biryani_adguard.nginx.enable rec {
                virtualHosts = {
                    "${biryani_adguard.nginx.hostname}" =
                        let
                            certDir = config.security.acme.certs."${biryani_adguard.nginx.hostname}".directory;
                        in
                        {
                            forceSSL = biryani_adguard.nginx.enable_ssl;
                            sslCertificate = "${certDir}/cert.pem";
                            sslCertificateKey = "${certDir}/key.pem";
                            locations."/" = {
                                proxyPass = "http://localhost:${toString biryani_adguard.port}";
                                extraConfig = ''
                                    proxy_http_version 1.1;
                                    proxy_set_header Upgrade $http_upgrade;
                                    proxy_set_header Connection 'upgrade';
                                    proxy_set_header Host $host;
                                    proxy_cache_bypass $http_upgrade;
                                '';
                            };
                        };
                    "*.${biryani_adguard.nginx.hostname}" = virtualHosts."${biryani_adguard.nginx.hostname}";
                };
            };

            networking.firewall.allowedTCPPorts = [
                853
                53
            ];
            networking.firewall.allowedUDPPorts = [
                853
                53
            ];
        };
}
