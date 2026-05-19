{ config, lib, ... }:
{
    options.biryani.services.virtualisation = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable host virtualisation and container support.";
        };

        docker = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable Docker on this host.";
            };

            rootless = lib.mkOption {
                type = lib.types.bool;
                description = "Enable Docker rootless mode.";
            };
        };

        containers = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable OCI container runtime integration.";
            };

            backend = lib.mkOption {
                type = lib.types.enum [
                    "docker"
                    "podman"
                ];
                description = "OCI container backend used by NixOS container definitions.";
            };
        };
    };

    config =
        let
            biryani_user = config.biryani.user;
            biryani_virtualisation = config.biryani.services.virtualisation;
        in
        lib.mkIf biryani_virtualisation.enable {
            users.users."${biryani_user.username}".extraGroups = [ "docker" ];

            virtualisation.docker = lib.mkIf biryani_virtualisation.docker.enable {
                enable = true;
                rootless.enable = biryani_virtualisation.docker.rootless;
            };

            virtualisation.oci-containers = lib.mkIf biryani_virtualisation.containers.enable {
                backend = biryani_virtualisation.containers.backend;
            };
        };
}
