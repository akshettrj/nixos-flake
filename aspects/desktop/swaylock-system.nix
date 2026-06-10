{ config, lib, ... }: {
    options.biryani.programs.screenlocks.swaylock.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable Swaylock system PAM integration.";
    };

    config =
        let
            biryani_screenlocks = config.biryani.programs.screenlocks;
        in
        lib.mkIf (biryani_screenlocks.enable && biryani_screenlocks.swaylock.enable) {
            security.pam.services.swaylock = { };
        };
}
