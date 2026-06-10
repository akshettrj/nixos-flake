{ config, lib, ... }: {
    options.biryani.shells.zsh.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable Zsh system integration.";
    };

    config =
        let
            biryani_shells = config.biryani.shells;
        in
        lib.mkIf biryani_shells.zsh.enable {
            environment.pathsToLink = [ "/share/zsh" ];

            programs.zsh.enable = true;
        };
}
