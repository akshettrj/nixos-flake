{ config, lib, ... }: {
    config =
        let
            biryani_shells = config.biryani.shells;
        in
        lib.mkIf biryani_shells.fzf.enable {
            programs.fzf = {
                enable = true;
                enableBashIntegration = lib.mkIf biryani_shells.bash.enable true;
                enableFishIntegration = lib.mkIf biryani_shells.fish.enable true;
                enableZshIntegration = lib.mkIf biryani_shells.zsh.enable true;
            };
        };
}
