{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_ss_tools = config.biryani.programs.screenshot_tools;
            biryani_theming = config.biryani.theming;
            palette =
                if biryani_theming.matugen.integrations.flameshot.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;

            ss_tools_meta = import ../../core/metadata/programs/screenshot_tools.nix { inherit pkgs; };
        in
        lib.mkIf (biryani_ss_tools.enable && biryani_ss_tools.flameshot.enable) {
            services.flameshot = {
                enable = true;
                settings = {
                    General = {
                        savePath = "${config.xdg.userDirs.pictures}/screenshots";
                        showDesktopNotification = true;
                        copyPathAfterSave = true;
                        showStartupLaunchMessage = false;
                        disabledTrayIcon = false;
                        contrastUiColor = palette.on_primary;
                        drawColor = palette.primary;
                        uiColor = palette.primary;
                    };
                };
            };

            home.packages = lib.attrValues (ss_tools_meta.flameshot.deps);
        };
}
