{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_media = config.biryani.programs.media;
            biryani_docs = biryani_media.documents;

            biryani_theming = config.biryani.theming;
            palette =
                if biryani_theming.matugen.integrations.zathura.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;
        in
        lib.mkIf (biryani_media.enable && biryani_docs.zathura.enable) {
            programs.zathura = {
                enable = true;
                package = (pkgs.zathura.override { useMupdf = biryani_docs.zathura.useMupdf; });

                mappings = {
                    R = "recolor";
                    "<Left>" = "navigate previous";
                    "<Right>" = "navigate next";
                    "<Button8>" = "navigate previous";
                    "<Button9>" = "navigate next";
                };

                options = {
                    window-title-basename = "true";
                    selection-clipboard = "clipboard";
                    scroll-page-aware = "true";
                    scroll-full-overlap = 1.0e-2;
                    zoom-min = 10;
                    guioptions = "";
                    adjust-open = "width";
                    render-loading = "false";
                    scroll-step = 50;

                    font = "${biryani_theming.fonts.main.name} ${toString (biryani_theming.fonts.main.size)}";
                    default-bg = palette.surface;
                    default-fg = palette.surface_container;

                    statusbar-fg = palette.on_surface;
                    statusbar-bg = palette.surface_container_high;

                    inputbar-bg = palette.surface;
                    inputbar-fg = palette.on_surface;

                    notification-bg = palette.surface_container;
                    notification-fg = palette.on_surface;

                    notification-error-bg = palette.error_container;
                    notification-error-fg = palette.on_error_container;

                    notification-warning-bg = palette.primary_container;
                    notification-warning-fg = palette.on_primary_container;

                    highlight-color = palette.primary_container;
                    highlight-active-color = palette.primary;

                    completion-bg = palette.surface_container;
                    completion-fg = palette.on_surface;

                    completion-highlight-fg = palette.on_primary_container;
                    completion-highlight-bg = palette.primary_container;

                    recolor-lightcolor = palette.surface;
                    recolor-darkcolor = palette.on_surface;

                    recolor = "false";
                    recolor-keephue = "false";
                };
            };
        };
}
