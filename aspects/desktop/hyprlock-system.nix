{ config, lib, ... }:
{
    options.biryani.programs.screenlocks.hyprlock.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable Hyprlock system PAM integration.";
    };

    config =
        let
            biryani_screenlocks = config.biryani.programs.screenlocks;
        in
        lib.mkIf (biryani_screenlocks.enable && biryani_screenlocks.hyprlock.enable) {
            security.pam.services.hyprlock = { };
        };
}
