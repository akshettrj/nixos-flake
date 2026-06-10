{ config, lib, ... }: {
    options.biryani = {
        dev.direnv.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable direnv and shell integration through Home Manager.";
        };

    };

    config =
        let
            biryani_dev = config.biryani.dev;
            biryani_shells = config.biryani.shells;
        in
        lib.mkIf biryani_dev.direnv.enable {
            programs.direnv = {
                enable = true;

                enableBashIntegration = lib.mkIf biryani_shells.bash.enable true;
                # Read-only option
                # enableFishIntegration = lib.mkIf biryani_shells.fish.enable true;
                enableNushellIntegration = lib.mkIf biryani_shells.nushell.enable true;
                enableZshIntegration = lib.mkIf biryani_shells.zsh.enable true;
            };
        };
}
