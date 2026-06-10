{ config, lib, ... }: {
    options.biryani.programs.browsers.firefox.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable Firefox through Home Manager.";
    };

    config =
        let
            biryani_browsers = config.biryani.programs.browsers;
        in
        lib.mkIf (biryani_browsers.enable && biryani_browsers.firefox.enable) {
            programs.firefox = {
                enable = true;
                configPath = "${config.xdg.configHome}/.mozilla/firefox";
            };
        };
}
