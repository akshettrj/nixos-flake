{ config, lib, ... }:
{
    options.biryani.programs.file_explorers.yazi.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable Yazi through Home Manager.";
    };

    config =
        let
            biryani_explorers = config.biryani.programs.file_explorers;
            biryani_shells = config.biryani.shells;
        in
        lib.mkIf biryani_explorers.yazi.enable {
            programs.yazi = {
                enable = true;
                shellWrapperName = "y";

                enableBashIntegration = lib.mkIf biryani_shells.bash.enable true;
                enableFishIntegration = lib.mkIf biryani_shells.fish.enable true;
                enableNushellIntegration = lib.mkIf biryani_shells.nushell.enable true;
                enableZshIntegration = lib.mkIf biryani_shells.zsh.enable true;

                settings = {
                    manager = {
                        # Sorting
                        sort_by = "natural";
                        sort_dir_first = true;
                        sort_sensitive = false;

                        # Visibility
                        show_hidden = true;
                        show_symlink = true;

                        title_format = "[yazi]: {cwd}";
                    };

                    preview = {
                        wrap = "yes";
                        tab_size = 2;
                        image_delay = 100;
                    };
                };
            };
        };
}
