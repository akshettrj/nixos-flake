{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.programs.browsers.chromium = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Chromium through Home Manager.";
        };

        cmd_args = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Command-line arguments passed to Chromium.";
        };

        extensions = lib.mkOption {
            type = lib.types.anything;
            description = "Chromium extension configuration passed through for future browser modules.";
        };
    };

    config =
        let
            biryani_browsers = config.biryani.programs.browsers;
        in
        lib.mkIf (biryani_browsers.enable && biryani_browsers.chromium.enable) {
            programs.chromium = {
                enable = true;
                commandLineArgs = biryani_browsers.chromium.cmd_args;
            };
        };
}
