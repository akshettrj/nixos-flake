{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.services.self_hosted.jellyfin = {
        enable = lib.mkEnableOption "Jellyfin media server on this host";

        intro_skipper.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
                Install the Intro Skipper plugin, which fingerprints episode audio to
                find intros/credits and publishes them as media segments, so clients
                show a "Skip Intro" button. Detection settings stay in the plugin's
                page in the dashboard.
            '';
        };

        backup.enable = lib.mkOption {
            type = lib.types.bool;
            default = config.biryani.services.backups.enable && config.biryani.services.backups.client.enable;
            defaultText = "config.biryani.services.backups.enable && config.biryani.services.backups.client.enable";
            description = ''
                Back up Jellyfin's state (users, watch history, settings, plugins and
                their databases, metadata) as the `jellyfin` Restic job. Jellyfin is
                stopped for the snapshot so its SQLite databases are consistent, which
                is why the job runs in the early morning, clear of the midnight
                Intro Skipper scan. Media itself is not included.
            '';
        };

        plugins = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = [ ];
            description = ''
                Plugin packages copied into Jellyfin's plugin directory before it
                starts. Each must set `passthru.jellyfinPlugin = { name; version;
                targetAbi; }` (see `jellyfin-plugins/`). Copies are writable because
                Jellyfin records its own metadata beside them; ones dropped from this
                list are removed, while plugins installed from the dashboard are left
                alone.
            '';
        };

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

        bind_dirs = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
            description = ''
                Directories Jellyfin cannot reach on its own (inside a private home
                directory, or owned by a group that does not exist on this host),
                keyed by the mount point that exposes each one to Jellyfin.

                Each is mounted read-only through bindfs, presented with group
                `jellyfin` and group read access added. The source keeps its own
                ownership and permissions, so tools that sync or manage it are
                unaffected. Like `media_dirs`, the Jellyfin unit is bound to these
                mounts.
            '';
            example = {
                "/srv/media/music" = "/home/alice/media/music";
            };
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

                biryani.services.self_hosted.jellyfin.plugins = lib.optional biryani_jellyfin.intro_skipper.enable (
                    pkgs.callPackage ./jellyfin-plugins/intro-skipper.nix { }
                );
            })

            (lib.mkIf (biryani_jellyfin.enable && biryani_jellyfin.backup.enable) {
                biryani.services.backups.client.jobs.jellyfin = {
                    # configDir sits inside dataDir by default; list it only if moved out.
                    paths = [
                        config.services.jellyfin.dataDir
                    ]
                    ++ lib.optional (
                        !lib.hasPrefix "${config.services.jellyfin.dataDir}/" config.services.jellyfin.configDir
                    ) config.services.jellyfin.configDir;
                    exclude = [ config.services.jellyfin.logDir ];
                    stopServices = [ "jellyfin.service" ];
                    timerConfig = {
                        OnCalendar = "*-*-* 04:00:00";
                        Persistent = true;
                    };
                };
            })

            (lib.mkIf (biryani_jellyfin.enable && biryani_jellyfin.plugins != [ ]) {
                assertions = map (
                    plugin:
                    let
                        inherit (plugin.jellyfinPlugin) name targetAbi;
                        server = config.services.jellyfin.package.version;
                    in
                    {
                        assertion =
                            lib.versions.majorMinor server == lib.versions.majorMinor targetAbi
                            && lib.versionAtLeast (lib.versions.pad 3 server) (lib.versions.pad 3 targetAbi);
                        message = "Jellyfin plugin `${name}` targets ABI ${targetAbi}, which Jellyfin ${server} cannot load; bump it in aspects/self-hosting/jellyfin-plugins/";
                    }
                ) biryani_jellyfin.plugins;

                # `.nix-managed` marks our copies (holding the store path they came
                # from) so stale ones are pruned and dashboard installs are not.
                systemd.services.jellyfin.preStart =
                    let
                        pluginsDir = "${config.services.jellyfin.dataDir}/plugins";
                        dirName = plugin: "${plugin.jellyfinPlugin.name}_${plugin.jellyfinPlugin.version}";
                        wanted = lib.escapeShellArgs (map dirName biryani_jellyfin.plugins);
                    in
                    ''
                        plugins_dir=${lib.escapeShellArg pluginsDir}
                        mkdir -p "$plugins_dir"

                        for dir in "$plugins_dir"/*/; do
                            dir=''${dir%/}
                            [ -e "$dir/.nix-managed" ] || continue
                            keep=
                            for name in ${wanted}; do
                                if [ "''${dir##*/}" = "$name" ]; then keep=1; fi
                            done
                            [ -n "$keep" ] || rm -rf -- "$dir"
                        done
                    ''
                    + lib.concatMapStrings (plugin: ''
                        dest="$plugins_dir"/${lib.escapeShellArg (dirName plugin)}
                        if [ "$(cat "$dest/.nix-managed" 2>/dev/null)" != ${plugin} ]; then
                            rm -rf -- "$dest"
                            cp -r --no-preserve=mode ${plugin} "$dest"
                            echo ${plugin} > "$dest/.nix-managed"
                        fi
                    '') biryani_jellyfin.plugins;
            })

            (lib.mkIf (biryani_jellyfin.enable && biryani_jellyfin.media_dirs != [ ]) {
                systemd.tmpfiles.rules = map (
                    dir: "d ${dir} 2750 ${biryani_user.username} ${config.services.jellyfin.group} - -"
                ) biryani_jellyfin.media_dirs;

                systemd.services.jellyfin.unitConfig.RequiresMountsFor = biryani_jellyfin.media_dirs;
            })

            (lib.mkIf (biryani_jellyfin.enable && biryani_jellyfin.bind_dirs != { }) {
                fileSystems = lib.mapAttrs (_: source: {
                    device = source;
                    fsType = "fuse.bindfs";
                    options = [
                        "ro"
                        "force-group=${config.services.jellyfin.group}"
                        "perms=g+rX"
                    ];
                }) biryani_jellyfin.bind_dirs;

                systemd.services.jellyfin.unitConfig.RequiresMountsFor = lib.attrNames biryani_jellyfin.bind_dirs;
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
