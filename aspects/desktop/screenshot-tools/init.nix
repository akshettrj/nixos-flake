{ config, lib, ... }: {
    options.biryani.programs.screenshot_tools = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Home Manager screenshot tooling.";
        };

        flameshot.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Flameshot screenshot service.";
        };

        wayshot.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Install Wayshot screenshot tooling.";
        };

        shotman.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Install Shotman screenshot tooling.";
        };

        hyprshot.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Install Hyprshot screenshot tooling.";
        };
    };

    config =
        let
            biryani_ss_tools = config.biryani.programs.screenshot_tools;

            ss_dir = "${config.xdg.userDirs.pictures}/screenshots";
        in
        lib.mkIf biryani_ss_tools.enable {
            # Make the screenshots directory
            home.activation.createScreenshotsDirectory =
                lib.hm.dag.entryAfter [ "writeBoundary" ] # sh

                    ''
                        [[ -L "${ss_dir}" ]] || run mkdir -p $VERBOSE_ARG "${ss_dir}"
                    '';
        };
}
