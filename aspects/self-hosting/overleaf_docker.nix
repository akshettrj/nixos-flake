{
    config,
    inputs,
    lib,
    ...
}:
{
    options.biryani.services.self_hosted.overleaf = {
        enable = lib.mkEnableOption "Overleaf";

        version = lib.mkOption {
            type = lib.types.str;
            description = "Docker image tag for the Overleaf container.";
        };

        data_dir = lib.mkOption {
            type = lib.types.oneOf [
                lib.types.str
                lib.types.path
            ];
            description = "Base data directory used by Overleaf and its backing containers.";
        };

        hostname = lib.mkOption {
            type = lib.types.str;
            description = "Primary public hostname for Overleaf.";
        };

        port = lib.mkOption {
            type = lib.types.port;
            description = "Local host port exposed by the Overleaf container.";
        };

        nginx = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable an Nginx virtual host for Overleaf.";
            };

            hostname = lib.mkOption {
                type = lib.types.str;
                description = "Public hostname for the Overleaf Nginx virtual host.";
            };

            enable_ssl = lib.mkOption {
                type = lib.types.bool;
                description = "Force SSL for the Overleaf Nginx virtual host.";
            };
        };
    };

    config =
        let
            biryani_nginx = config.biryani.services.nginx;
            biryani_overleaf = config.biryani.services.self_hosted.overleaf;
        in
        lib.mkIf biryani_overleaf.enable {
            assertions = [
                {
                    assertion = if biryani_overleaf.nginx.enable then biryani_nginx.enable else true;
                    message = "Vikunja's nginx is enabled, but global nginx is not";
                }
            ];

            systemd.services.docker-network-overleaf = inputs.rubikoid_base.lib.r.mkDockerNet config "overleaf";

            virtualisation.oci-containers.containers = {
                overleaf-redis = {
                    image = "redis";
                    volumes = [ "${biryani_overleaf.data_dir}-redis:/data" ];
                    extraOptions = [ "--network=overleaf-net" ];
                };

                overleaf-db = {
                    image = "mongo:5.0.31-rc0";
                    cmd = [
                        "--replSet"
                        "rs0"
                    ];
                    environment = {
                        FERRETDB_HANDLER = "sqlite";
                    };
                    volumes = [ "${biryani_overleaf.data_dir}-db:/data/db" ];
                    extraOptions = [ "--network=overleaf-net" ];
                };

                overleaf = {
                    image = "sharelatex/sharelatex:${biryani_overleaf.version}";
                    environment =
                        let
                            redis = "overleaf-redis";
                        in
                        {
                            OVERLEAF_APP_NAME = "Overleaf (The PropheC)";

                            ENABLED_LINKED_FILE_TYPES = "project_file,project_output_file";
                            ENABLE_CONVERSIONS = "true";

                            OVERLEAF_MONGO_URL = "mongodb://overleaf-db/overleaf";
                            OVERLEAF_REDIS_HOST = redis;
                            REDIS_HOST = redis;
                        };
                    ports = [ "${toString biryani_overleaf.port}:80" ];
                    volumes = [ "${biryani_overleaf.data_dir}:/var/lib/overleaf" ];
                    extraOptions = [ "--network=overleaf-net" ];
                };
            };

            services.nginx = lib.mkIf biryani_overleaf.nginx.enable {
                virtualHosts."${biryani_overleaf.nginx.hostname}" =
                    let
                        certDir = config.security.acme.certs."${biryani_overleaf.hostname}".directory;
                    in
                    {
                        forceSSL = biryani_overleaf.nginx.enable_ssl;
                        sslCertificate = "${certDir}/cert.pem";
                        sslCertificateKey = "${certDir}/key.pem";
                        locations."/" = {
                            proxyPass = "http://localhost:${toString biryani_overleaf.port}";
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
