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
            palette =
                if biryani_theming.matugen.integrations.qt.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;
        in
        lib.mkIf (biryani_theming.enable && biryani_theming.qt) {
            qt = {
                enable = true;
                platformTheme.name = "qtct";
                style.name = "kvantum";
            };

            home.packages = [
                pkgs.libsForQt5.qt5ct
                pkgs.kdePackages.qt6ct
                pkgs.libsForQt5.qtstyleplugin-kvantum
                pkgs.kdePackages.qtstyleplugin-kvantum
            ];

            home.sessionVariables = lib.mkIf biryani_theming.matugen.integrations.qt.enable {
                QT_STYLE_OVERRIDE = "kvantum";
            };

            xdg.configFile = lib.mkIf biryani_theming.matugen.integrations.qt.enable {
                "Kvantum/kvantum.kvconfig".text = ''
                    [General]
                    theme=Matugen
                '';

                "Kvantum/Matugen/Matugen.kvconfig".text = ''
                    [%General]
                    author=matugen
                    comment=Generated from biryani.theming.palette
                    x11drag=menubar_and_primary_toolbar
                    alt_mnemonic=true
                    left_tabs=true
                    attach_active_tab=true
                    mirror_doc_tabs=true
                    group_toolbar_buttons=false
                    toolbar_item_spacing=0
                    toolbar_interior_spacing=4
                    spread_progressbar=true
                    composite=true
                    menu_shadow_depth=4
                    tooltip_shadow_depth=4
                    splitter_width=1
                    scroll_width=8
                    scroll_arrows=false
                    transient_scrollbar=true
                    slider_width=4
                    slider_handle_width=18
                    slider_handle_length=18
                    check_size=16
                    textless_progressbar=false
                    progressbar_thickness=6
                    menubar_mouse_tracking=true
                    toolbutton_style=1
                    double_click=false
                    no_window_pattern=false
                    translucent_windows=false
                    reduce_window_opacity=0
                    reduce_menu_opacity=0
                    respect_DE=true
                    force_size_grip=true

                    [GeneralColors]
                    window.color=${palette.surface}
                    base.color=${palette.surface_container_low}
                    alt.base.color=${palette.surface_container}
                    button.color=${palette.surface_container_high}
                    light.color=${palette.surface_container_highest}
                    mid.light.color=${palette.surface_container_high}
                    dark.color=${palette.surface_container_lowest}
                    mid.color=${palette.surface_container}
                    highlight.color=${palette.primary_container}
                    inactive.highlight.color=${palette.surface_container_high}
                    text.color=${palette.on_surface}
                    window.text.color=${palette.on_surface}
                    button.text.color=${palette.on_surface}
                    highlight.text.color=${palette.on_primary_container}
                    link.color=${palette.primary}
                    link.visited.color=${palette.tertiary}
                    progress.indicator.text.color=${palette.on_primary_container}

                    [Hacks]
                    transparent_dolphin_view=false
                    transparent_pcmanfm_sidepane=false
                    blur_translucent=false
                    center_doc_tabs=true
                    kinetic_scrolling=false

                    [PanelButtonCommand]
                    frame=true
                    interior=true
                    indicator.size=8

                    [PanelButtonTool]
                    frame=true
                    interior=true
                    indicator.size=8

                    [Toolbar]
                    frame=true
                    interior=true

                    [Focus]
                    frame=true
                    color=${palette.primary}

                    [Selection]
                    frame=true
                    color=${palette.primary_container}

                    [Tooltip]
                    frame=true
                    interior=true

                    [Menu]
                    frame=true
                    interior=true

                    [Scrollbar]
                    frame=true
                    interior=true
                '';

                "Kvantum/Matugen/Matugen.svg".text = ''
                    <svg xmlns="http://www.w3.org/2000/svg" width="8" height="8">
                      <rect width="8" height="8" fill="${palette.surface}"/>
                    </svg>
                '';

                "qt5ct/qt5ct.conf".text = ''
                    [Appearance]
                    color_scheme_path=
                    custom_palette=false
                    icon_theme=Papirus-Dark
                    standard_dialogs=default
                    style=kvantum

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
                    color_scheme_path=
                    custom_palette=false
                    icon_theme=Papirus-Dark
                    standard_dialogs=default
                    style=kvantum

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
            };
        };
}
