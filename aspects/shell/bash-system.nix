{ config, lib, ... }:
{
    options.biryani.shells.bash.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable system integration for Bash completion files.";
    };

    config =
        let
            biryani_shells = config.biryani.shells;
        in
        lib.mkIf biryani_shells.bash.enable { environment.pathsToLink = [ "/share/bash-completion" ]; };
}
