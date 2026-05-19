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
                    };
                };
            };

            home.packages = lib.attrValues (ss_tools_meta.flameshot.deps);
        };
}
