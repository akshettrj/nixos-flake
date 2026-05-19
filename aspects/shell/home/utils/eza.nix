{ config, lib, ... }:
{
    config =
        let
            biryani_shells = config.biryani.shells;
        in
        lib.mkIf biryani_shells.eza.enable {
            programs.eza = {
                enable = true;
                enableBashIntegration = lib.mkIf biryani_shells.bash.enable true;
                enableFishIntegration = lib.mkIf biryani_shells.fish.enable true;
                enableNushellIntegration = lib.mkIf biryani_shells.nushell.enable true;
                enableZshIntegration = lib.mkIf biryani_shells.zsh.enable true;
                git = true;
                icons = "auto";
            };
        };
}
