{ config, lib, ... }:
{
    options.biryani.programs.browsers.chrome = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Google Chrome through Home Manager.";
        };

        cmd_args = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Command-line arguments passed to Google Chrome.";
        };

        extensions = lib.mkOption {
            type = lib.types.anything;
            description = "Google Chrome extension configuration passed through for future browser modules.";
        };
    };

    config =
        let
            biryani_browsers = config.biryani.programs.browsers;
        in
        lib.mkIf (biryani_browsers.enable && biryani_browsers.chrome.enable) {
            programs.google-chrome = {
                enable = true;
                commandLineArgs = biryani_browsers.chrome.cmd_args;
            };
        };
}
