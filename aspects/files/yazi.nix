{ config, lib, ... }: {
    options.biryani.programs.file_explorers.yazi.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable Yazi through Home Manager.";
    };

    config =
        let
            biryani_explorers = config.biryani.programs.file_explorers;
            biryani_shells = config.biryani.shells;
            biryani_theming = config.biryani.theming;
            palette =
                if biryani_theming.matugen.integrations.yazi.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;
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

                theme = {
                    manager = {
                        cwd = {
                            fg = palette.primary;
                        };
                        hovered = {
                            fg = palette.on_primary_container;
                            bg = palette.primary_container;
                        };
                        preview_hovered = {
                            fg = palette.on_primary_container;
                            bg = palette.primary_container;
                        };
                        find_keyword = {
                            fg = palette.on_primary_container;
                            bg = palette.primary_container;
                        };
                        find_position = {
                            fg = palette.on_secondary_container;
                            bg = palette.secondary_container;
                        };
                        marker_copied = {
                            fg = palette.secondary;
                            bg = palette.secondary;
                        };
                        marker_cut = {
                            fg = palette.error;
                            bg = palette.error;
                        };
                        marker_marked = {
                            fg = palette.tertiary;
                            bg = palette.tertiary;
                        };
                        tab_active = {
                            fg = palette.on_primary_container;
                            bg = palette.primary_container;
                        };
                        tab_inactive = {
                            fg = palette.on_surface;
                            bg = palette.surface_container;
                        };
                        border_symbol = "│";
                        border_style = {
                            fg = palette.outline;
                        };
                    };
                    status = {
                        separator_open = "";
                        separator_close = "";
                        mode_normal = {
                            fg = palette.on_primary;
                            bg = palette.primary;
                        };
                        mode_select = {
                            fg = palette.on_secondary;
                            bg = palette.secondary;
                        };
                        mode_unset = {
                            fg = palette.on_error;
                            bg = palette.error;
                        };
                        progress_label = {
                            fg = palette.on_surface;
                        };
                        progress_normal = {
                            fg = palette.primary;
                            bg = palette.surface_container;
                        };
                        progress_error = {
                            fg = palette.error;
                            bg = palette.surface_container;
                        };
                    };
                    input = {
                        border = {
                            fg = palette.outline;
                        };
                        title = {
                            fg = palette.primary;
                        };
                        selected = {
                            bg = palette.primary_container;
                        };
                    };
                    select = {
                        border = {
                            fg = palette.outline;
                        };
                        active = {
                            fg = palette.primary;
                        };
                    };
                    tasks = {
                        border = {
                            fg = palette.outline;
                        };
                        title = {
                            fg = palette.primary;
                        };
                        hovered = {
                            fg = palette.on_primary_container;
                            bg = palette.primary_container;
                        };
                    };
                };
            };
        };
}
