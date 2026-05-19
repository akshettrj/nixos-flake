{ config, lib, ... }:
{
    options.biryani.programs.browsers = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable browser configuration through Home Manager.";
        };

        brave = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable Brave through Home Manager.";
            };

            cmd_args = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = "Command-line arguments passed to Brave.";
            };
        };
    };

    config =
        let
            biryani_browsers = config.biryani.programs.browsers;
        in
        lib.mkIf (biryani_browsers.enable && biryani_browsers.brave.enable) {
            programs.brave = {
                enable = true;
                commandLineArgs = biryani_browsers.brave.cmd_args;
            };
        };
}
