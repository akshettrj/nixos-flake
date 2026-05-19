{ config, lib, ... }:
{
    options.biryani.shells.fish.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable Fish shell system integration.";
    };

    config =
        let
            biryani_shells = config.biryani.shells;
        in
        lib.mkIf biryani_shells.fish.enable {
            environment.pathsToLink = [ "/share/fish" ];

            programs.fish.enable = true;
        };
}
