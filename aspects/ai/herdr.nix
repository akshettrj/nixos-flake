{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_ai = config.biryani.programs.ai;
            biryani_herdr = biryani_ai.herdr;
            biryani_theming = config.biryani.theming;
            useMatugen = biryani_theming.matugen.integrations.herdr.enable;
            palette = if useMatugen then biryani_theming.palette.matugen else biryani_theming.palette.static;
            # The static palette is gruvbox-dark; matugen follows its mode.
            isLight = useMatugen && biryani_theming.matugen.enable && biryani_theming.matugen.mode == "light";
        in
        lib.mkIf (biryani_ai.enable && biryani_herdr.enable) {
            # `herdr` is a terminal multiplexer for coding agents. The upstream
            # Home Manager module defaults `package` to `pkgs.herdr`, but the
            # llm-agents overlay tracks upstream releases more closely.
            programs.herdr = {
                enable = true;
                package = pkgs.llm-agents.herdr;
                settings = {
                    onboarding = false;
                    # Surfaces, text and accent come from the palette. The
                    # agent-state hues (green/yellow/blue/teal/peach) stay with
                    # the base theme: matugen's base16 reuses primary/secondary
                    # for those slots, which would make e.g. "working" and
                    # "done" indistinguishable. `sidebar_bg` keeps its `reset`
                    # default to preserve the terminal background/transparency.
                    theme.name = if isLight then "gruvbox-light" else "gruvbox";
                    theme.custom = {
                        accent = palette.primary;
                        panel_bg = palette.surface_container_low;
                        active_row_bg = palette.surface_container;
                        selection_bg = palette.surface_container_high;
                        surface0 = palette.surface_container_high;
                        surface1 = palette.surface_container_highest;
                        surface_dim = palette.surface_container;
                        overlay0 = palette.outline;
                        overlay1 = palette.on_surface_variant;
                        text = palette.on_surface;
                        subtext0 = palette.on_surface_variant;
                        mauve = palette.tertiary;
                        red = palette.error;
                    };
                };
            };
        };
}
