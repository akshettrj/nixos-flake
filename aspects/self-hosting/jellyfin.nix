{ config, lib, ... }: {
    options.biryani.services.self_hosted.jellyfin = {
        enable = lib.mkEnableOption "Jellyfin media server on this host";

        media_dirs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = ''
                Library directories Jellyfin reads media from. Each is created owned
                by the primary user and group `jellyfin` (mode 2750, setgid so new
                files stay readable by Jellyfin). Libraries themselves are still
                added in the web UI.

                The Jellyfin unit is bound to the mounts holding these paths, so it
                refuses to start while one is unavailable instead of scanning an
                empty directory and dropping the library's items.
            '';
            example = [ "/mnt/hdd/media" ];
        };

        reverse_proxy = {
            enable = lib.mkEnableOption "public Nginx reverse-proxy virtual host for a remote Jellyfin";

            hostname = lib.mkOption {
                type = lib.types.str;
                description = "Public hostname served by the reverse-proxy virtual host.";
            };

            upstream_host = lib.mkOption {
                type = lib.types.str;
                description = "Upstream host running Jellyfin (e.g. a Tailscale MagicDNS name).";
            };

            upstream_port = lib.mkOption {
                type = lib.types.port;
                default = 8096;
                description = "Upstream Jellyfin HTTP port.";
            };

            enable_ssl = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Force SSL for the reverse-proxy virtual host.";
            };

            max_body_size = lib.mkOption {
                type = lib.types.str;
                default = "20M";
                description = "client_max_body_size for the reverse-proxy virtual host (artwork/subtitle uploads).";
            };
        };
    };

    config =
        let
            biryani_jellyfin = config.biryani.services.self_hosted.jellyfin;
            biryani_nginx = config.biryani.services.nginx;
            biryani_user = config.biryani.user;
            rp = biryani_jellyfin.reverse_proxy;
        in
        lib.mkMerge [
            (lib.mkIf biryani_jellyfin.enable {
                # Port 8096 is deliberately not opened: the server is reached over
                # the trusted tailscale0 interface, publicly only via reverse_proxy.
                services.jellyfin.enable = true;
            })

            (lib.mkIf (biryani_jellyfin.enable && biryani_jellyfin.media_dirs != [ ]) {
                systemd.tmpfiles.rules = map (
                    dir: "d ${dir} 2750 ${biryani_user.username} ${config.services.jellyfin.group} - -"
                ) biryani_jellyfin.media_dirs;

                systemd.services.jellyfin.unitConfig.RequiresMountsFor = biryani_jellyfin.media_dirs;
            })

            (lib.mkIf rp.enable {
                assertions = [
                    {
                        assertion = biryani_nginx.enable;
                        message = "Jellyfin reverse_proxy is enabled, but global nginx (biryani.services.nginx.enable) is not";
                    }
                ];

                services.nginx.virtualHosts."${rp.hostname}" =
                    let
                        certDir = config.security.acme.certs."${rp.hostname}".directory;
                    in
                    {
                        forceSSL = rp.enable_ssl;
                        sslCertificate = "${certDir}/cert.pem";
                        sslCertificateKey = "${certDir}/key.pem";
                        extraConfig = ''
                            client_max_body_size ${rp.max_body_size};
                        '';
                        locations."/" = {
                            proxyPass = "http://${rp.upstream_host}:${toString rp.upstream_port}";
                            # Covers Jellyfin's `/socket` endpoint (SyncPlay, remote control).
                            proxyWebsockets = true;
                            extraConfig = ''
                                proxy_set_header Host $host;
                                proxy_set_header X-Real-IP $remote_addr;
                                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                                proxy_set_header X-Forwarded-Proto $scheme;
                                proxy_set_header X-Forwarded-Protocol $scheme;
                                proxy_set_header X-Forwarded-Host $http_host;
                                # Stream straight through instead of spooling video to disk.
                                proxy_buffering off;
                            '';
                        };
                    };
            })
        ];
}
