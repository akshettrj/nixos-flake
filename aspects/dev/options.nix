{ lib, ... }:
{
    options.biryani.dev = {
        git = {
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

        direnv.enable = lib.mkEnableOption "direnv shell integration.";
        cachix.enable = lib.mkEnableOption "Cachix command-line tooling.";
    };
}
