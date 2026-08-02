{
    config,
    lib,
    pkgs,
    ...
}:
let
    inherit (lib)
        mkEnableOption
        mkIf
        mkOption
        optionalAttrs
        types
        ;

    cfg = config.biryani.services;
    backupCfg = cfg.backups;
    syncCfg = cfg.sync;
    permissionManagedFolders = lib.filterAttrs (_: folder: folder.permissions != null) syncCfg.folders;

    resticJobType = types.submodule {
        options = {
            paths = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "Paths included in this Restic backup job.";
            };

            exclude = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "Restic exclude patterns for this backup job.";
            };

            timerConfig = mkOption {
                type = types.nullOr (types.attrsOf types.anything);
                default = {
                    OnCalendar = "daily";
                    Persistent = true;
                };
                description = "Systemd timer configuration for this Restic backup job.";
            };

            pruneOpts = mkOption {
                type = types.listOf types.str;
                default = [
                    "--keep-daily 7"
                    "--keep-weekly 4"
                    "--keep-monthly 12"
                ];
                description = "Restic forget --prune retention options for this backup job.";
            };
        };
    };

    syncthingDeviceType = types.submodule {
        freeformType = types.attrsOf types.anything;
        options.id = mkOption {
            type = types.str;
            description = "Syncthing device ID.";
        };
    };

    syncthingFolderType = types.submodule {
        options = {
            path = mkOption {
                type = types.str;
                description = "Local path for the synced folder.";
            };

            devices = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "Names of configured Syncthing devices that should receive this folder.";
            };

            versioning = mkOption {
                type = types.nullOr (types.attrsOf types.anything);
                default = null;
                description = "Optional Syncthing versioning settings for this folder.";
            };

            permissions = mkOption {
                type = types.nullOr (
                    types.submodule {
                        options = {
                            owner = mkOption {
                                type = types.str;
                                description = "Owner recursively enforced for the synced folder.";
                            };

                            group = mkOption {
                                type = types.str;
                                description = "Group recursively enforced for the synced folder.";
                            };

                            mode = mkOption {
                                type = types.strMatching "0?[0-7]{3}";
                                description = "Mode recursively enforced for the synced folder.";
                            };

                            enforcementInterval = mkOption {
                                type = types.str;
                                default = "1m";
                                description = "How often to repair ownership and permissions after synchronization.";
                            };
                        };
                    }
                );
                default = null;
                description = "Optional recursive local ownership and permissions enforcement.";
            };
        };
    };

    resticRepository =
        jobName:
        "sftp:restic@${backupCfg.client.repositoryHost}:${backupCfg.client.repositoryPath}/${config.networking.hostName}/${jobName}";

    resticSftpCommand = "sftp.command='ssh restic@${backupCfg.client.repositoryHost} -i ${backupCfg.client.sshKeyFile} -s sftp'";
in
{
    options.biryani.services = {
        backups = {
            enable = mkEnableOption "data backups.";

            receiver = {
                enable = mkEnableOption "Restic backup receiver.";

                storagePath = mkOption {
                    type = types.str;
                    default = "/srv/storage/restic";
                    description = "Root directory used to store incoming Restic repositories.";
                };
            };

            client = {
                enable = mkEnableOption "Restic backup client jobs.";

                repositoryHost = mkOption {
                    type = types.str;
                    default = "raspi";
                    description = "Host name of the Restic SFTP receiver.";
                };

                repositoryPath = mkOption {
                    type = types.str;
                    default = "/srv/storage/restic";
                    description = ''
                        Absolute path of the Restic repository root **on the receiver
                        host**. This must match that host's
                        `biryani.services.backups.receiver.storagePath`. The two live in
                        separate NixOS configurations, so they cannot be derived from one
                        another and must be kept in step by hand.
                    '';
                };

                passwordFile = mkOption {
                    type = types.str;
                    default = "/etc/secrets/restic-password";
                    description = "Path to the Restic repository password file.";
                };

                sshKeyFile = mkOption {
                    type = types.str;
                    default = "/etc/secrets/restic-ssh-key";
                    description = "Path to the SSH private key used by Restic SFTP jobs.";
                };

                jobs = mkOption {
                    type = types.attrsOf resticJobType;
                    default = { };
                    description = "Restic backup jobs keyed by job name.";
                };
            };
        };

        sync = {
            enable = mkEnableOption "Syncthing directory synchronization.";

            user = mkOption {
                type = types.str;
                default = config.biryani.user.username;
                description = "User account that runs Syncthing.";
            };

            group = mkOption {
                type = types.str;
                default = "users";
                description = "Primary group for the Syncthing service.";
            };

            dataDir = mkOption {
                type = types.str;
                default = "/home/${syncCfg.user}/.local/state/syncthing";
                description = "Syncthing data directory.";
            };

            devices = mkOption {
                type = types.attrsOf syncthingDeviceType;
                default = { };
                description = "Declarative Syncthing devices.";
            };

            folders = mkOption {
                type = types.attrsOf syncthingFolderType;
                default = {
                    music.path = "/home/${syncCfg.user}/media/music";
                };
                description = "Declarative Syncthing folders.";
            };
        };
    };

    config = lib.mkMerge [
        (mkIf (backupCfg.enable && backupCfg.receiver.enable) {
            users.groups.restic = { };
            users.users.restic = {
                isSystemUser = true;
                group = "restic";
                home = backupCfg.receiver.storagePath;
                createHome = false;
                shell = pkgs.bashInteractive;
            };

            systemd.tmpfiles.rules = [ "d ${backupCfg.receiver.storagePath} 0700 restic restic - -" ];

            services.openssh.extraConfig = ''
                Match User restic
                    ForceCommand internal-sftp
                    AllowTcpForwarding no
                    X11Forwarding no
                    PermitTTY no
                    PasswordAuthentication no
            '';
        })

        (mkIf (backupCfg.enable && backupCfg.client.enable) {
            services.restic.backups = lib.mapAttrs (jobName: job: {
                paths = job.paths;
                exclude = job.exclude;
                repository = resticRepository jobName;
                passwordFile = backupCfg.client.passwordFile;
                timerConfig = job.timerConfig;
                pruneOpts = job.pruneOpts;
                initialize = true;
                extraOptions = [ resticSftpCommand ];
            }) backupCfg.client.jobs;
        })

        (mkIf syncCfg.enable {
            systemd.tmpfiles.rules =
                lib.mapAttrsToList (
                    _: folder:
                    if folder.permissions == null then
                        "d ${folder.path} 0755 ${syncCfg.user} ${syncCfg.group} - -"
                    else
                        "d ${folder.path} ${folder.permissions.mode} ${folder.permissions.owner} ${folder.permissions.group} - -"
                ) syncCfg.folders
                ++ lib.mapAttrsToList (
                    _: folder:
                    "Z ${folder.path} ${folder.permissions.mode} ${folder.permissions.owner} ${folder.permissions.group} - -"
                ) permissionManagedFolders;

            systemd.services =
                lib.mapAttrs' (
                    name: folder:
                    lib.nameValuePair "syncthing-permissions-${name}" {
                        description = "Repair permissions for Syncthing folder ${name}";
                        serviceConfig.Type = "oneshot";
                        script = ''
                            ${pkgs.findutils}/bin/find ${lib.escapeShellArg folder.path} \
                                -exec ${pkgs.coreutils}/bin/chown ${lib.escapeShellArg "${folder.permissions.owner}:${folder.permissions.group}"} {} + \
                                -exec ${pkgs.coreutils}/bin/chmod ${lib.escapeShellArg folder.permissions.mode} {} +
                        '';
                    }
                ) permissionManagedFolders
                // {
                    syncthing.serviceConfig.UMask = lib.mkIf (permissionManagedFolders != { }) "0007";
                };

            systemd.timers = lib.mapAttrs' (
                name: folder:
                lib.nameValuePair "syncthing-permissions-${name}" {
                    description = "Periodically repair permissions for Syncthing folder ${name}";
                    wantedBy = [ "timers.target" ];
                    timerConfig = {
                        OnBootSec = "1m";
                        OnUnitActiveSec = folder.permissions.enforcementInterval;
                    };
                }
            ) permissionManagedFolders;

            services.syncthing = {
                enable = true;
                user = syncCfg.user;
                group = syncCfg.group;
                dataDir = syncCfg.dataDir;
                configDir = "${syncCfg.dataDir}/config";
                openDefaultPorts = true;
                overrideDevices = false;
                overrideFolders = false;
                settings = {
                    devices = lib.mapAttrs (name: device: { inherit name; } // device) syncCfg.devices;
                    folders = lib.mapAttrs (
                        name: folder:
                        {
                            enable = true;
                            id = name;
                            label = name;
                            path = folder.path;
                            devices = folder.devices;
                        }
                        // optionalAttrs (folder.versioning != null) { versioning = folder.versioning; }
                        // optionalAttrs (folder.permissions != null) { ignorePerms = true; }
                    ) syncCfg.folders;
                };
            };

        })
    ];
}
