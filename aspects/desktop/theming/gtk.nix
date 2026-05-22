{
    config,
    pkgs,
    lib,
    ...
}:
{
    config =
        let
            biryani_theming = config.biryani.theming;
            palette =
                if biryani_theming.matugen.integrations.gtk.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;
            gtkThemeName = if biryani_theming.matugen.mode == "dark" then "adw-gtk3-dark" else "adw-gtk3";
            gtkCss = ''
                @define-color accent_color ${palette.primary};
                @define-color accent_bg_color ${palette.primary};
                @define-color accent_fg_color ${palette.on_primary};
                @define-color destructive_color ${palette.error};
                @define-color destructive_bg_color ${palette.error};
                @define-color destructive_fg_color ${palette.on_error};
                @define-color window_bg_color ${palette.surface};
                @define-color window_fg_color ${palette.on_surface};
                @define-color view_bg_color ${palette.surface_container_low};
                @define-color view_fg_color ${palette.on_surface};
                @define-color headerbar_bg_color ${palette.surface_container};
                @define-color headerbar_fg_color ${palette.on_surface};
                @define-color popover_bg_color ${palette.surface_container};
                @define-color popover_fg_color ${palette.on_surface};
                @define-color card_bg_color ${palette.surface_container};
                @define-color card_fg_color ${palette.on_surface};
                @define-color sidebar_bg_color ${palette.surface_container_low};
                @define-color sidebar_fg_color ${palette.on_surface};
                @define-color borders ${palette.outline};

                * {
                  caret-color: ${palette.primary};
                }

                window,
                .background {
                  background-color: ${palette.surface};
                  color: ${palette.on_surface};
                }

                headerbar,
                .titlebar,
                popover,
                menu,
                dialog {
                  background-color: ${palette.surface_container};
                  color: ${palette.on_surface};
                }

                entry,
                textview,
                treeview,
                list,
                viewport {
                  background-color: ${palette.surface_container_low};
                  color: ${palette.on_surface};
                  border-color: ${palette.outline};
                }

                button,
                combobox,
                spinbutton {
                  background-color: ${palette.surface_container_high};
                  color: ${palette.on_surface};
                  border-color: ${palette.outline};
                }

                button:checked,
                button.suggested-action,
                row:selected,
                selection {
                  background-color: ${palette.primary_container};
                  color: ${palette.on_primary_container};
                }

                button.destructive-action,
                error {
                  background-color: ${palette.error_container};
                  color: ${palette.on_error_container};
                }
            '';
        in
        lib.mkIf (biryani_theming.enable && biryani_theming.gtk) {
            gtk = {
                enable = true;
                cursorTheme = {
                    package = biryani_theming.cursor.package;
                    name = biryani_theming.cursor.name;
                    size = biryani_theming.cursor.size;
                };
                font = {
                    name = biryani_theming.fonts.main.name;
                    size = biryani_theming.fonts.main.size;
                };
                iconTheme = {
                    package = pkgs.papirus-icon-theme;
                    name = "Papirus-Dark";
                };
                theme = {
                    package = pkgs.adw-gtk3;
                    name = gtkThemeName;
                };
                gtk3 = {
                    bookmarks = [
                        "file:///tmp"
                        "file://${config.home.homeDirectory}/media"
                    ];
                };
                gtk4 = {
                    theme = null;
                };
            };

            home.packages = [ pkgs.lxappearance ];

            home.sessionVariables = lib.mkIf biryani_theming.matugen.integrations.gtk.enable {
                GTK_THEME = gtkThemeName;
            };

            dconf.settings = lib.mkIf biryani_theming.matugen.integrations.gtk.enable {
                "org/gnome/desktop/interface" = {
                    color-scheme = if biryani_theming.matugen.mode == "dark" then "prefer-dark" else "prefer-light";
                    gtk-theme = gtkThemeName;
                };
            };

            xdg.configFile = lib.mkIf biryani_theming.matugen.integrations.gtk.enable {
                "gtk-3.0/gtk.css".text = gtkCss;
                "gtk-4.0/gtk.css".text = gtkCss;
            };
        };
}
