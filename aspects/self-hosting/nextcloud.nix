{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.services.self_hosted.nextcloud = {
        enable = lib.mkEnableOption "Nextcloud server on this host";

        package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.nextcloud34;
            description = ''
                Nextcloud package to run. Declaring this explicitly also silences the
                module's "legacy install" warning, which is emitted purely on the basis
                of an old `system.stateVersion`.

                Nextcloud cannot upgrade across more than one major version at a time,
                so bump this one major release at a time on hosts that already hold an
                instance, and let each upgrade finish before the next.
            '';
        };

        hostname = lib.mkOption {
            type = lib.types.str;
            description = "Public FQDN of the Nextcloud instance (trusted domain and generated-link host).";
        };

        admin_user = lib.mkOption {
            type = lib.types.str;
            default = "admin";
            description = "Initial Nextcloud admin username.";
        };

        admin_pass_file = lib.mkOption {
            type = lib.types.str;
            default = "/var/lib/nextcloud-admin-pass";
            description = ''
                Path to a file holding the initial admin password. Must exist on the
                host before first activation; only read on initial install.
            '';
        };

        data_dir = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
                Storage path for Nextcloud's config and user data. Null keeps the
                module default (`/var/lib/nextcloud`). When this points at a
                separate mount, the Nextcloud units are bound to that mount so
                they refuse to start while it is unavailable, instead of writing
                a second copy of the data onto the underlying filesystem.
            '';
            example = "/mnt/hdd/nextcloud";
        };

        max_upload_size = lib.mkOption {
            type = lib.types.str;
            default = "2G";
            description = ''
                Maximum upload size. Note the Nextcloud NixOS module also uses this
                value for PHP's memory_limit, so keep it modest on low-RAM hosts.
            '';
        };

        trusted_proxies = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "100.64.0.0/10" ];
            description = ''
                Addresses/CIDRs trusted as reverse proxies. Defaults to the Tailscale
                CGNAT range so the public proxy host is trusted.
            '';
        };

        reverse_proxy = {
            enable = lib.mkEnableOption "public Nginx reverse-proxy virtual host for a remote Nextcloud";

            hostname = lib.mkOption {
                type = lib.types.str;
                description = "Public hostname served by the reverse-proxy virtual host.";
            };

            upstream_host = lib.mkOption {
                type = lib.types.str;
                description = "Upstream host running Nextcloud (e.g. a Tailscale MagicDNS name).";
            };

            upstream_port = lib.mkOption {
                type = lib.types.port;
                default = 80;
                description = "Upstream Nextcloud HTTP port.";
            };

            enable_ssl = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Force SSL for the reverse-proxy virtual host.";
            };

            max_body_size = lib.mkOption {
                type = lib.types.str;
                default = "2G";
                description = "client_max_body_size for the reverse-proxy virtual host.";
            };
        };
    };

    config =
        let
            biryani_nextcloud = config.biryani.services.self_hosted.nextcloud;
            biryani_nginx = config.biryani.services.nginx;
            biryani_user = config.biryani.user;
            rp = biryani_nextcloud.reverse_proxy;
        in
        lib.mkMerge [
            (lib.mkIf biryani_nextcloud.enable {
                # The data directory is 0750, so group membership is what lets the
                # primary user read Nextcloud's files directly on disk.
                users.users."${biryani_user.username}".extraGroups = [ "nextcloud" ];

                services.nextcloud = {
                    enable = true;
                    package = biryani_nextcloud.package;
                    hostName = biryani_nextcloud.hostname;
                    https = true;
                    maxUploadSize = biryani_nextcloud.max_upload_size;

                    datadir = lib.mkIf (biryani_nextcloud.data_dir != null) biryani_nextcloud.data_dir;

                    database.createLocally = true;

                    config = {
                        dbtype = "pgsql";
                        adminuser = biryani_nextcloud.admin_user;
                        adminpassFile = biryani_nextcloud.admin_pass_file;
                    };

                    settings = {
                        overwriteprotocol = "https";
                        overwritehost = biryani_nextcloud.hostname;
                        "overwrite.cli.url" = "https://${biryani_nextcloud.hostname}";
                        trusted_domains = [ biryani_nextcloud.hostname ];
                        trusted_proxies = biryani_nextcloud.trusted_proxies;
                    };
                };
            })

            (lib.mkIf (biryani_nextcloud.enable && biryani_nextcloud.data_dir != null) {
                # The Nextcloud module creates `<datadir>/config` and `<datadir>/data`,
                # but any missing parent is created as root:root 0755, which fails the
                # module's own "config is not owned by user 'nextcloud'" check. Own the
                # parent explicitly.
                systemd.tmpfiles.rules = [ "d ${biryani_nextcloud.data_dir} 0750 nextcloud nextcloud - -" ];

                # Bind the units to the data mount so they never initialise a second,
                # empty instance on the underlying filesystem while the disk is absent.
                systemd.services =
                    lib.genAttrs [ "nextcloud-setup" "nextcloud-cron" "nextcloud-update-plugins" "phpfpm-nextcloud" ]
                        (_: {
                            unitConfig.RequiresMountsFor = [ biryani_nextcloud.data_dir ];
                        });
            })

            (lib.mkIf rp.enable {
                assertions = [
                    {
                        assertion = biryani_nginx.enable;
                        message = "Nextcloud reverse_proxy is enabled, but global nginx (biryani.services.nginx.enable) is not";
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
                            proxy_request_buffering off;
                        '';
                        locations."/" = {
                            proxyPass = "http://${rp.upstream_host}:${toString rp.upstream_port}";
                            proxyWebsockets = true;
                            extraConfig = ''
                                proxy_set_header Host $host;
                                proxy_set_header X-Real-IP $remote_addr;
                                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                                proxy_set_header X-Forwarded-Proto $scheme;
                                proxy_buffering off;
                                proxy_read_timeout 3600s;
                                proxy_send_timeout 3600s;
                            '';
                        };
                    };
            })
        ];
}
