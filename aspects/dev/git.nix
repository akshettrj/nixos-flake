{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.dev.git = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Git configuration through Home Manager.";
        };

        user = {
            name = lib.mkOption {
                type = lib.types.str;
                description = "Git author name.";
            };

            email = lib.mkOption {
                type = lib.types.str;
                description = "Git author email address.";
            };
        };

        delta.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable delta as the Git pager/diff viewer.";
        };

        default_branch = lib.mkOption {
            type = lib.types.str;
            description = "Default branch name used by newly initialized Git repositories.";
        };
    };

    config =
        let
            biryani_dev = config.biryani.dev;
        in
        lib.mkIf biryani_dev.git.enable {
            programs.git = {
                enable = true;
                settings = {
                    init.defaultBranch = biryani_dev.git.default_branch;
                    user = {
                        name = biryani_dev.git.user.name;
                        email = biryani_dev.git.user.email;
                    };
                };
            };

            programs.delta.enable = biryani_dev.git.delta.enable;

            home.packages = [ pkgs.gitu ];
        };
}
