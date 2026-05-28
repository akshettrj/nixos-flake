{
    config,
    lib,
    pkgs,
    ...
}:
let
    cfg = config.biryani.services.self_hosted.postgresql;
in
{
    options.biryani.services.self_hosted.postgresql = {
        enable = lib.mkEnableOption "self-hosted PostgreSQL database.";

        package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.postgresql_16;
            description = "PostgreSQL package to run.";
        };

        dataDir = lib.mkOption {
            type = lib.types.str;
            default = "/var/lib/postgresql/${cfg.package.psqlSchema}";
            description = "PostgreSQL data directory.";
        };

        socketDir = lib.mkOption {
            type = lib.types.str;
            default = "/run/postgresql";
            description = "Directory used for PostgreSQL Unix sockets.";
        };

        socketGroup = lib.mkOption {
            type = lib.types.str;
            default = "postgres";
            description = "Group allowed to reach the PostgreSQL Unix socket.";
        };

        allowedLocalUsers = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Local Unix users allowed to connect through the PostgreSQL socket.";
        };

        databases = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Databases created declaratively.";
        };

        ensureUsers = lib.mkOption {
            type = lib.types.listOf (
                lib.types.submodule {
                    freeformType = lib.types.attrsOf lib.types.anything;
                    options.name = lib.mkOption {
                        type = lib.types.str;
                        description = "PostgreSQL role name.";
                    };
                }
            );
            default = [ ];
            description = "PostgreSQL roles created declaratively.";
        };

        settings = lib.mkOption {
            type = lib.types.attrsOf (
                lib.types.oneOf [
                    lib.types.bool
                    lib.types.int
                    lib.types.float
                    lib.types.str
                ]
            );
            default = { };
            description = "Extra postgresql.conf settings merged over hardened local-only defaults.";
        };
    };

    config = lib.mkIf cfg.enable {
        assertions = [
            {
                assertion = !(cfg.settings ? listen_addresses);
                message = "biryani.services.self_hosted.postgresql.settings.listen_addresses is managed by the hardened module.";
            }
            {
                assertion = !(cfg.settings ? unix_socket_permissions);
                message = "biryani.services.self_hosted.postgresql.settings.unix_socket_permissions is managed by the hardened module.";
            }
            {
                assertion = !(cfg.settings ? unix_socket_directories);
                message = "biryani.services.self_hosted.postgresql.settings.unix_socket_directories is managed by the hardened module.";
            }
        ];

        users.users = lib.genAttrs cfg.allowedLocalUsers (_: {
            extraGroups = [ cfg.socketGroup ];
        });

        services.postgresql = {
            enable = true;
            package = cfg.package;
            dataDir = cfg.dataDir;
            enableTCPIP = false;
            ensureDatabases = cfg.databases;
            ensureUsers = cfg.ensureUsers;
            authentication = lib.mkForce ''
                local all all peer
            '';
            settings = {
                listen_addresses = lib.mkForce "";
                password_encryption = "scram-sha-256";
                ssl = false;
                unix_socket_directories = lib.mkForce cfg.socketDir;
                unix_socket_group = cfg.socketGroup;
                unix_socket_permissions = lib.mkForce "0770";
            }
            // cfg.settings;
        };

        systemd.services.postgresql.serviceConfig = {
            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            RestrictAddressFamilies = lib.mkForce [ "AF_UNIX" ];
            RestrictNamespaces = true;
            RestrictRealtime = true;
            SystemCallArchitectures = "native";
        };
    };
}
