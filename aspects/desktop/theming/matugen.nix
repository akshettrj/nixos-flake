{
    config,
    lib,
    pkgs,
    ...
}:
let
    cfg = config.biryani.theming.matugen;
    mode = cfg.mode;
    mkIntegrationEnable =
        name: lib.mkEnableOption "matugen palette integration for ${name}." // { default = true; };

    staticPalette = rec {
        background = "#282828";
        error = "#fb4934";
        error_container = "#cc241d";
        on_error = "#282828";
        on_error_container = "#fbf1c7";
        on_primary = "#282828";
        on_primary_container = "#fbf1c7";
        on_secondary = "#282828";
        on_secondary_container = "#fbf1c7";
        on_surface = "#ebdbb2";
        on_surface_variant = "#d5c4a1";
        outline = "#928374";
        outline_variant = "#665c54";
        primary = "#d79921";
        primary_container = "#504945";
        secondary = "#b8bb26";
        secondary_container = "#3c3836";
        surface = background;
        surface_container = "#3c3836";
        surface_container_high = "#504945";
        surface_container_highest = "#665c54";
        surface_container_low = "#32302f";
        surface_container_lowest = "#1d2021";
        surface_variant = "#504945";
        tertiary = "#8ec07c";
        tertiary_container = "#427b58";

        base16 = {
            base00 = "#282828";
            base01 = "#3c3836";
            base02 = "#504945";
            base03 = "#665c54";
            base04 = "#bdae93";
            base05 = "#d5c4a1";
            base06 = "#ebdbb2";
            base07 = "#fbf1c7";
            base08 = "#fb4934";
            base09 = "#fe8019";
            base0a = "#fabd2f";
            base0b = "#b8bb26";
            base0c = "#8ec07c";
            base0d = "#83a598";
            base0e = "#d3869b";
            base0f = "#d65d0e";
        };
    };

    matugenJson =
        pkgs.runCommandLocal "matugen-palette.json"
            {
                nativeBuildInputs = [ pkgs.matugen ];
                preferLocalBuild = true;
            }
            ''
                matugen \
                  --mode ${lib.escapeShellArg cfg.mode} \
                  --type ${lib.escapeShellArg cfg.scheme} \
                  --source-color-index ${toString cfg.source_color_index} \
                  --fallback-color ${lib.escapeShellArg cfg.fallback_color} \
                  --json hex \
                  --include-image-in-json false \
                  --dry-run \
                  image ${lib.escapeShellArg (toString config.biryani.theming.wallpaper)} > "$out"
            '';

    matugenData = builtins.fromJSON (builtins.readFile matugenJson);
    color = name: matugenData.colors.${name}.${mode}.color or matugenData.colors.${name}.default.color;
    tone =
        palette: value:
        matugenData.palettes.${palette}.${value}.color
            or matugenData.palettes.${palette}.${toString value}.color;

    matugenPalette = {
        background = color "background";
        error = color "error";
        error_container = color "error_container";
        inverse_surface = color "inverse_surface";
        on_error = color "on_error";
        on_error_container = color "on_error_container";
        on_primary = color "on_primary";
        on_primary_container = color "on_primary_container";
        on_secondary = color "on_secondary";
        on_secondary_container = color "on_secondary_container";
        on_surface = color "on_surface";
        on_surface_variant = color "on_surface_variant";
        outline = color "outline";
        outline_variant = color "outline_variant";
        primary = color "primary";
        primary_container = color "primary_container";
        secondary = color "secondary";
        secondary_container = color "secondary_container";
        surface = color "surface";
        surface_container = color "surface_container";
        surface_container_high = color "surface_container_high";
        surface_container_highest = color "surface_container_highest";
        surface_container_low = color "surface_container_low";
        surface_container_lowest = color "surface_container_lowest";
        surface_variant = color "surface_variant";
        tertiary = color "tertiary";
        tertiary_container = color "tertiary_container";

        base16 =
            if mode == "dark" then
                {
                    base00 = color "surface";
                    base01 = color "surface_container";
                    base02 = color "surface_container_high";
                    base03 = color "outline";
                    base04 = color "on_surface_variant";
                    base05 = color "on_surface";
                    base06 = tone "neutral" "90";
                    base07 = tone "neutral" "95";
                    base08 = color "error";
                    base09 = tone "tertiary" "80";
                    base0a = color "primary";
                    base0b = color "secondary";
                    base0c = color "tertiary";
                    base0d = tone "primary" "80";
                    base0e = tone "secondary" "80";
                    base0f = tone "error" "80";
                }
            else
                {
                    base00 = color "surface";
                    base01 = color "surface_container";
                    base02 = color "surface_container_high";
                    base03 = color "outline";
                    base04 = color "on_surface_variant";
                    base05 = color "on_surface";
                    base06 = tone "neutral" "20";
                    base07 = tone "neutral" "10";
                    base08 = color "error";
                    base09 = tone "tertiary" "40";
                    base0a = color "primary";
                    base0b = color "secondary";
                    base0c = color "tertiary";
                    base0d = tone "primary" "40";
                    base0e = tone "secondary" "40";
                    base0f = tone "error" "40";
                };
    };
in
{
    options.biryani.theming = {
        matugen = {
            enable = lib.mkEnableOption "matugen wallpaper-derived palette generation.";
            mode = lib.mkOption {
                type = lib.types.enum [
                    "dark"
                    "light"
                ];
                default = "dark";
                description = "matugen color mode.";
            };
            scheme = lib.mkOption {
                type = lib.types.enum [
                    "scheme-content"
                    "scheme-expressive"
                    "scheme-fidelity"
                    "scheme-fruit-salad"
                    "scheme-monochrome"
                    "scheme-neutral"
                    "scheme-rainbow"
                    "scheme-tonal-spot"
                    "scheme-vibrant"
                ];
                default = "scheme-tonal-spot";
                description = "matugen Material color scheme type.";
            };
            source_color_index = lib.mkOption {
                type = lib.types.ints.unsigned;
                default = 0;
                description = "matugen source color candidate index used for non-interactive palette generation.";
            };
            fallback_color = lib.mkOption {
                type = lib.types.strMatching "#[0-9a-fA-F]{6}";
                default = "#6750a4";
                description = "Fallback source color used by matugen if wallpaper extraction fails.";
            };
            integrations = {
                alacritty.enable = mkIntegrationEnable "Alacritty";
                bat.enable = mkIntegrationEnable "bat";
                bemenu.enable = mkIntegrationEnable "bemenu";
                btop.enable = mkIntegrationEnable "btop";
                dunst.enable = mkIntegrationEnable "Dunst";
                flameshot.enable = mkIntegrationEnable "Flameshot";
                ghostty.enable = mkIntegrationEnable "Ghostty";
                gtk.enable = mkIntegrationEnable "GTK";
                hyprland.enable = mkIntegrationEnable "Hyprland";
                hyprlock.enable = mkIntegrationEnable "Hyprlock";
                ncmpcpp.enable = mkIntegrationEnable "ncmpcpp";
                qt.enable = mkIntegrationEnable "Qt";
                swaylock.enable = mkIntegrationEnable "Swaylock";
                swaync.enable = mkIntegrationEnable "SwayNotificationCenter";
                waybar.enable = mkIntegrationEnable "Waybar";
                wezterm.enable = mkIntegrationEnable "WezTerm";
                yazi.enable = mkIntegrationEnable "Yazi";
                zathura.enable = mkIntegrationEnable "Zathura";
            };
        };

        palette = lib.mkOption {
            type = lib.types.attrs;
            readOnly = true;
            description = "Resolved desktop color palette used by Home Manager modules.";
        };
    };

    config.biryani.theming.palette = {
        active = if cfg.enable then matugenPalette else staticPalette;
        matugen = if cfg.enable then matugenPalette else staticPalette;
        static = staticPalette;
    };
}
