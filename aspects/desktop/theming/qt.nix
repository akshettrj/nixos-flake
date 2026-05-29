{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_theming = config.biryani.theming;
            iconTheme = biryani_theming.icon_theme;
            palette =
                if biryani_theming.matugen.integrations.qt.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;
            hexByte = value: (builtins.fromTOML "x = 0x${value}").x;
            stripHash = color: lib.removePrefix "#" color;
            argb = color: "#ff${stripHash color}";
            rgb =
                color:
                let
                    value = stripHash color;
                    r = hexByte (builtins.substring 0 2 value);
                    g = hexByte (builtins.substring 2 2 value);
                    b = hexByte (builtins.substring 4 2 value);
                in
                "${toString r},${toString g},${toString b}";
            qtColorLine = colors: lib.concatStringsSep ", " (map argb colors);
            qtColorEntry = [
                palette.on_background
                palette.surface
                "#ffffff"
                "#cacaca"
                "#9f9f9f"
                "#b8b8b8"
                palette.on_background
                "#ffffff"
                palette.on_surface
                palette.background
                palette.background
                palette.shadow
                palette.primary_container
                palette.on_primary_container
                palette.secondary
                palette.primary
                palette.surface
                palette.scrim
                palette.surface
                palette.on_surface
                palette.secondary
            ];
            qtColorScheme = ''
                [ColorScheme]
                active_colors=${qtColorLine qtColorEntry}
                disabled_colors=${qtColorLine qtColorEntry}
                inactive_colors=${qtColorLine qtColorEntry}
            '';
            qt5ColorSchemePath = "${config.home.homeDirectory}/.config/qt5ct/colors/matugen.conf";
            qt6ColorSchemePath = "${config.home.homeDirectory}/.config/qt6ct/colors/matugen.conf";
            kdeglobals = ''
                [ColorEffects:Disabled]
                Color=${rgb palette.surface_dim}
                ColorAmount=0
                ColorEffect=0
                ContrastAmount=0.65
                ContrastEffect=1
                IntensityAmount=0.1
                IntensityEffect=2

                [ColorEffects:Inactive]
                ChangeSelectionColor=true
                Color=${rgb palette.surface_variant}
                ColorAmount=0.025
                ColorEffect=2
                ContrastAmount=0.1
                ContrastEffect=2
                Enable=false
                IntensityAmount=0
                IntensityEffect=0

                [Colors:Button]
                BackgroundAlternate=${rgb palette.surface_container_low}
                BackgroundNormal=${rgb palette.surface_container_high}
                DecorationFocus=${rgb palette.primary}
                DecorationHover=${rgb palette.primary}
                ForegroundActive=${rgb palette.primary}
                ForegroundInactive=${rgb palette.on_surface_variant}
                ForegroundLink=${rgb palette.secondary}
                ForegroundNegative=${rgb palette.error}
                ForegroundNeutral=${rgb palette.tertiary}
                ForegroundNormal=${rgb palette.on_surface}
                ForegroundPositive=${rgb palette.tertiary_fixed}
                ForegroundVisited=${rgb palette.on_secondary_container}

                [Colors:Complementary]
                BackgroundAlternate=${rgb palette.surface_container_low}
                BackgroundNormal=${rgb palette.surface}
                DecorationFocus=${rgb palette.primary}
                DecorationHover=${rgb palette.primary}
                ForegroundActive=${rgb palette.primary}
                ForegroundInactive=${rgb palette.on_surface_variant}
                ForegroundLink=${rgb palette.secondary}
                ForegroundNegative=${rgb palette.error}
                ForegroundNeutral=${rgb palette.tertiary}
                ForegroundNormal=${rgb palette.on_primary_container}
                ForegroundPositive=${rgb palette.tertiary_fixed}
                ForegroundVisited=${rgb palette.on_secondary_container}

                [Colors:Header]
                BackgroundAlternate=${rgb palette.surface}
                BackgroundNormal=${rgb palette.surface_container}
                DecorationFocus=${rgb palette.primary}
                DecorationHover=${rgb palette.primary}
                ForegroundActive=${rgb palette.primary}
                ForegroundInactive=${rgb palette.on_surface_variant}
                ForegroundLink=${rgb palette.secondary}
                ForegroundNegative=${rgb palette.error}
                ForegroundNeutral=${rgb palette.tertiary}
                ForegroundNormal=${rgb palette.on_surface}
                ForegroundPositive=${rgb palette.tertiary_fixed}
                ForegroundVisited=${rgb palette.on_secondary_container}

                [Colors:Header][Inactive]
                BackgroundAlternate=${rgb palette.surface_container}
                BackgroundNormal=${rgb palette.surface_container}
                DecorationFocus=${rgb palette.primary}
                DecorationHover=${rgb palette.primary}
                ForegroundActive=${rgb palette.primary}
                ForegroundInactive=${rgb palette.on_surface_variant}
                ForegroundLink=${rgb palette.secondary}
                ForegroundNegative=${rgb palette.error}
                ForegroundNeutral=${rgb palette.tertiary}
                ForegroundNormal=${rgb palette.on_surface}
                ForegroundPositive=${rgb palette.tertiary_fixed}
                ForegroundVisited=${rgb palette.on_secondary_container}

                [Colors:Selection]
                BackgroundAlternate=${rgb palette.surface_container_low}
                BackgroundNormal=${rgb palette.primary}
                DecorationFocus=${rgb palette.primary}
                DecorationHover=${rgb palette.primary}
                ForegroundActive=${rgb palette.on_primary}
                ForegroundInactive=${rgb palette.on_surface_variant}
                ForegroundLink=${rgb palette.secondary_fixed}
                ForegroundNegative=${rgb palette.error_container}
                ForegroundNeutral=${rgb palette.tertiary_fixed_dim}
                ForegroundNormal=${rgb palette.secondary_fixed}
                ForegroundPositive=${rgb palette.tertiary_container}
                ForegroundVisited=${rgb palette.on_secondary_container}

                [Colors:Tooltip]
                BackgroundAlternate=${rgb palette.surface}
                BackgroundNormal=${rgb palette.surface_container}
                DecorationFocus=${rgb palette.primary}
                DecorationHover=${rgb palette.primary}
                ForegroundActive=${rgb palette.primary}
                ForegroundInactive=${rgb palette.on_surface_variant}
                ForegroundLink=${rgb palette.secondary}
                ForegroundNegative=${rgb palette.error}
                ForegroundNeutral=${rgb palette.tertiary}
                ForegroundNormal=${rgb palette.on_background}
                ForegroundPositive=${rgb palette.tertiary_fixed}
                ForegroundVisited=${rgb palette.on_secondary_container}

                [Colors:View]
                BackgroundAlternate=${rgb palette.surface_container}
                BackgroundNormal=${rgb palette.background}
                DecorationFocus=${rgb palette.primary_container}
                DecorationHover=${rgb palette.on_primary}
                ForegroundActive=${rgb palette.primary}
                ForegroundInactive=${rgb palette.on_surface_variant}
                ForegroundLink=${rgb palette.secondary}
                ForegroundNegative=${rgb palette.error}
                ForegroundNeutral=${rgb palette.tertiary}
                ForegroundNormal=${rgb palette.on_background}
                ForegroundPositive=${rgb palette.tertiary_fixed}
                ForegroundVisited=${rgb palette.on_secondary_container}

                [Colors:Window]
                BackgroundAlternate=${rgb palette.primary_container}
                BackgroundNormal=${rgb palette.surface_container}
                DecorationFocus=${rgb palette.primary}
                DecorationHover=${rgb palette.primary}
                ForegroundActive=${rgb palette.primary}
                ForegroundInactive=${rgb palette.on_surface_variant}
                ForegroundLink=${rgb palette.secondary}
                ForegroundNegative=${rgb palette.error}
                ForegroundNeutral=${rgb palette.tertiary}
                ForegroundNormal=${rgb palette.on_background}
                ForegroundPositive=${rgb palette.tertiary_fixed}
                ForegroundVisited=${rgb palette.on_secondary_container}

                [General]
                ColorScheme=Matugen
                Name=Matugen

                [Icons]
                Theme=${iconTheme.name}

                [KDE]
                contrast=4
                widgetStyle=qt6ct-style

                [WM]
                activeBackground=${rgb palette.primary_container}
                activeBlend=${rgb palette.on_primary_container}
                activeForeground=${rgb palette.on_primary_container}
                inactiveBackground=${rgb palette.surface}
                inactiveBlend=${rgb palette.on_surface_variant}
                inactiveForeground=${rgb palette.on_surface_variant}
            '';
            kvantumConfig = ''
                [%General]
                author=Generated by biryani
                inherits=KvAdaptaDark
                translucent_windows=true
                blurring=true
                popup_blurring=true
                reduce_window_opacity=15

                [GeneralColors]
                window.color=${palette.surface}
                base.color=${palette.surface_container_highest}
                alt.base.color=${palette.surface_container_low}
                button.color=${palette.surface_bright}
                light.color=${palette.surface_bright}
                mid.light.color=${palette.surface_variant}
                dark.color=${palette.surface}
                mid.color=${palette.surface_container_low}
                highlight.color=${palette.primary}
                inactive.highlight.color=${palette.primary_fixed_dim}
                text.color=${palette.on_surface}
                window.text.color=${palette.on_surface}
                button.text.color=${palette.on_surface}
                disabled.text.color=${palette.inverse_on_surface}
                tooltip.text.color=${palette.on_surface}
                highlight.text.color=${palette.on_surface}
                link.color=${palette.primary}
                link.visited.color=${palette.tertiary_fixed_dim}
                progress.indicator.text.color=${palette.on_surface}

                [Hacks]
                transparent_ktitle_label=true
                transparent_dolphin_view=true
                transparent_pcmanfm_sidepane=true
                blur_translucent=true
                transparent_menutitle=true
                respect_darkness=true
                kcapacitybar_as_progressbar=true
                force_size_grip=true
            '';
        in
        lib.mkIf (biryani_theming.enable && biryani_theming.qt) {
            qt = {
                enable = true;
                platformTheme.name = "qtct";
                style.name = "qt6ct-style";
            };

            home.packages = [
                pkgs.libsForQt5.qt5ct
                pkgs.kdePackages.qt6ct
                iconTheme.package
            ];

            home.sessionVariables = lib.mkIf biryani_theming.matugen.integrations.qt.enable {
                QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
                QT_STYLE_OVERRIDE = lib.mkForce "qt6ct-style";
                QT_PLUGIN_PATH = lib.mkForce "${config.home.profileDirectory}/lib/qt-6/plugins";
            };

            xdg.configFile = lib.mkIf biryani_theming.matugen.integrations.qt.enable {
                "kdeglobals".text = kdeglobals;

                "Kvantum/matugen/matugen.kvconfig".text = kvantumConfig;
                "Kvantum/kvantum.kvconfig".text = ''
                    [General]
                    theme=matugen
                '';

                "qt5ct/qt5ct.conf".text = ''
                    [Appearance]
                    color_scheme_path=${qt5ColorSchemePath}
                    custom_palette=true
                    icon_theme=${iconTheme.name}
                    standard_dialogs=default
                    style=qt6ct-style

                    [Fonts]
                    fixed="${biryani_theming.fonts.main.name},${toString biryani_theming.fonts.main.size},-1,5,50,0,0,0,0,0"
                    general="${biryani_theming.fonts.main.name},${toString biryani_theming.fonts.main.size},-1,5,50,0,0,0,0,0"

                    [Interface]
                    activate_item_on_single_click=1
                    buttonbox_layout=0
                    cursor_flash_time=1000
                    dialog_buttons_have_icons=1
                    double_click_interval=400
                    gui_effects=@Invalid()
                    keyboard_scheme=2
                    menus_have_icons=true
                    show_shortcuts_in_context_menus=true
                    stylesheets=@Invalid()
                    toolbutton_style=4
                    underline_shortcut=1
                    wheel_scroll_lines=3
                '';

                "qt6ct/qt6ct.conf".text = ''
                    [Appearance]
                    color_scheme_path=${qt6ColorSchemePath}
                    custom_palette=true
                    icon_theme=${iconTheme.name}
                    standard_dialogs=default
                    style=qt6ct-style

                    [Fonts]
                    fixed="${biryani_theming.fonts.main.name},${toString biryani_theming.fonts.main.size},-1,5,50,0,0,0,0,0"
                    general="${biryani_theming.fonts.main.name},${toString biryani_theming.fonts.main.size},-1,5,50,0,0,0,0,0"

                    [Interface]
                    activate_item_on_single_click=1
                    buttonbox_layout=0
                    cursor_flash_time=1000
                    dialog_buttons_have_icons=1
                    double_click_interval=400
                    gui_effects=@Invalid()
                    keyboard_scheme=2
                    menus_have_icons=true
                    show_shortcuts_in_context_menus=true
                    stylesheets=@Invalid()
                    toolbutton_style=4
                    underline_shortcut=1
                    wheel_scroll_lines=3
                '';

                "qt5ct/colors/matugen.conf".text = qtColorScheme;
                "qt6ct/colors/matugen.conf".text = qtColorScheme;
            };

            xdg.dataFile = lib.mkIf biryani_theming.matugen.integrations.qt.enable {
                "color-schemes/Matugen.colors".text = kdeglobals;
            };
        };
}
