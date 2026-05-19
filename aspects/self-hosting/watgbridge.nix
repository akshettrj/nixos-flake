{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.services.self_hosted.watgbridge =
        let
            instanceType = lib.types.submodule {
                options = {
                    enabled = lib.mkOption {
                        type = lib.types.bool;
                        description = "Enable this WaTgBridge instance.";
                    };

                    package = lib.mkOption {
                        type = lib.types.package;
                        default = inputs.watgbridge.packages."${pkgs.stdenv.hostPlatform.system}".default;
                        description = "WaTgBridge package used by this instance.";
                    };

                    instance_name = lib.mkOption {
                        type = lib.types.str;
                        description = "Instance name used in the systemd unit name.";
                    };

                    config_file = lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        description = "Optional WaTgBridge configuration file path.";
                    };

                    user = lib.mkOption {
                        type = lib.types.str;
                        description = "User that runs this WaTgBridge instance.";
                    };

                    group = lib.mkOption {
                        type = lib.types.str;
                        description = "Group that runs this WaTgBridge instance.";
                    };

                    max_runtime = lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        description = "Optional RuntimeMaxSec value for the systemd unit.";
                    };

                    working_directory = lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        description = "Optional working directory for the systemd unit.";
                    };

                    after = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        description = "Additional systemd units ordered before this instance.";
                    };

                    requires = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        description = "Additional systemd units required by this instance.";
                    };
                };
            };
        in
        {
            enable = lib.mkEnableOption "WaTgBridge service instances";

            settings = lib.mkOption {
                type = lib.types.listOf instanceType;
                description = "WaTgBridge instance definitions.";
            };
        };

    config =
        let
            biryani_watgbridge = config.biryani.services.self_hosted.watgbridge;
            setting_to_service_mapper = (
                setting: {
                    name = "watgbridge-${setting.instance_name}";
                    value =
                        let
                            config_file_arg = if setting.config_file != null then (" " + setting.config_file) else "";
                        in
                        {
                            description = "WaTgBridge for instance ${setting.instance_name}";
                            after = [ "network.target" ] ++ setting.after;
                            requires = [ "network.target" ] ++ setting.requires;
                            wantedBy = [ ] ++ lib.optionals setting.enabled [ "multi-user.target" ];

                            path = with pkgs; [
                                ffmpeg
                                imagemagick
                                libwebp
                            ];

                            serviceConfig = {
                                User = setting.user;
                                Group = setting.group;
                                Type = "exec";
                                Restart = "on-failure";
                                ExecStart = "${setting.package}/bin/watgbridge" + config_file_arg;
                            }
                            // (lib.optionalAttrs (setting.max_runtime != null) { RuntimeMaxSec = setting.max_runtime; })
                            // (lib.optionalAttrs (setting.working_directory != null) {
                                WorkingDirectory = setting.working_directory;
                            });
                        };
                }
            );
        in
        lib.mkIf biryani_watgbridge.enable {
            systemd.services = (
                biryani_watgbridge.settings |> builtins.map setting_to_service_mapper |> builtins.listToAttrs
            );
        };
}
