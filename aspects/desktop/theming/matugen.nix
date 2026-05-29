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
    hexByte = value: (builtins.fromTOML "x = 0x${value}").x;
    hexRgb =
        color:
        let
            hex = lib.removePrefix "#" color;
        in
        {
            r = hexByte (builtins.substring 0 2 hex);
            g = hexByte (builtins.substring 2 2 hex);
            b = hexByte (builtins.substring 4 2 hex);
        };
    square = value: value * value;
    colorDistance =
        left: right:
        let
            a = hexRgb left;
            b = hexRgb right;
        in
        square (a.r - b.r) + square (a.g - b.g) + square (a.b - b.b);
    papirusFolderColors = {
        adwaita = "#9141ac";
        black = "#3d3846";
        blue = "#4877b1";
        bluegrey = "#4d646f";
        breeze = "#3daee9";
        brown = "#957552";
        carmine = "#7a0002";
        cyan = "#00acc1";
        darkcyan = "#00838f";
        deeporange = "#e95420";
        green = "#60924b";
        grey = "#727272";
        indigo = "#3f51b5";
        magenta = "#b259b8";
        nordic = "#81a1c1";
        orange = "#dd772f";
        palebrown = "#c7a57b";
        paleorange = "#ffa726";
        pink = "#ec407a";
        red = "#bf4b4b";
        teal = "#12806a";
        violet = "#5d399b";
        white = "#e4e4e4";
        yaru = "#e95420";
        yellow = "#e19d00";
    };
    closestPapirusFolderColor =
        color:
        let
            candidates = lib.mapAttrsToList (name: value: {
                inherit name;
                distance = colorDistance color value;
            }) papirusFolderColors;
        in
        (lib.foldl' (
            best: candidate: if candidate.distance < best.distance then candidate else best
        ) (lib.head candidates) (lib.tail candidates)).name;

    staticPalette = rec {
        background = "#282828";
        error = "#fb4934";
        error_container = "#cc241d";
        inverse_on_surface = "#282828";
        inverse_surface = "#fbf1c7";
        on_background = "#ebdbb2";
        on_error = "#282828";
        on_error_container = "#fbf1c7";
        on_primary = "#282828";
        on_primary_container = "#fbf1c7";
        on_primary_fixed = "#282828";
        on_secondary = "#282828";
        on_secondary_container = "#fbf1c7";
        on_surface = "#ebdbb2";
        on_surface_variant = "#d5c4a1";
        outline = "#928374";
        outline_variant = "#665c54";
        primary = "#d79921";
        primary_container = "#504945";
        primary_fixed_dim = "#b57614";
        scrim = "#000000";
        secondary = "#b8bb26";
        secondary_container = "#3c3836";
        secondary_fixed = "#b8bb26";
        shadow = "#000000";
        surface = background;
        surface_bright = "#3c3836";
        surface_container = "#3c3836";
        surface_container_high = "#504945";
        surface_container_highest = "#665c54";
        surface_container_low = "#32302f";
        surface_container_lowest = "#1d2021";
        surface_dim = "#1d2021";
        surface_variant = "#504945";
        tertiary = "#8ec07c";
        tertiary_container = "#427b58";
        tertiary_fixed = "#8ec07c";
        tertiary_fixed_dim = "#689d6a";

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
        inverse_on_surface = color "inverse_on_surface";
        inverse_surface = color "inverse_surface";
        on_background = color "on_background";
        on_error = color "on_error";
        on_error_container = color "on_error_container";
        on_primary = color "on_primary";
        on_primary_container = color "on_primary_container";
        on_primary_fixed = color "on_primary_fixed";
        on_secondary = color "on_secondary";
        on_secondary_container = color "on_secondary_container";
        on_surface = color "on_surface";
        on_surface_variant = color "on_surface_variant";
        outline = color "outline";
        outline_variant = color "outline_variant";
        primary = color "primary";
        primary_container = color "primary_container";
        primary_fixed_dim = color "primary_fixed_dim";
        scrim = color "scrim";
        secondary = color "secondary";
        secondary_container = color "secondary_container";
        secondary_fixed = color "secondary_fixed";
        shadow = color "shadow";
        surface = color "surface";
        surface_bright = color "surface_bright";
        surface_container = color "surface_container";
        surface_container_high = color "surface_container_high";
        surface_container_highest = color "surface_container_highest";
        surface_container_low = color "surface_container_low";
        surface_container_lowest = color "surface_container_lowest";
        surface_dim = color "surface_dim";
        surface_variant = color "surface_variant";
        tertiary = color "tertiary";
        tertiary_container = color "tertiary_container";
        tertiary_fixed = color "tertiary_fixed";
        tertiary_fixed_dim = color "tertiary_fixed_dim";

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
    papirusFolderColor = closestPapirusFolderColor (
        if mode == "dark" then matugenPalette.primary_container else matugenPalette.primary
    );
    papirusBaseThemeName = if mode == "dark" then "Papirus-Dark" else "Papirus-Light";
    matugenIconThemeName = if mode == "dark" then "Matugen-Papirus-Dark" else "Matugen-Papirus-Light";
    matugenIconTheme =
        pkgs.runCommandLocal "matugen-papirus-icon-theme-${mode}-${papirusFolderColor}"
            { preferLocalBuild = true; }
            ''
                mkdir -p "$out/share/icons"
                mkdir -p "$out/share/icons/${matugenIconThemeName}"
                cp -a ${pkgs.papirus-icon-theme}/share/icons/Papirus/. "$out/share/icons/${matugenIconThemeName}/"
                chmod -R u+w "$out/share/icons/${matugenIconThemeName}"
                sed -i 's/^Name=.*/Name=${matugenIconThemeName}/' "$out/share/icons/${matugenIconThemeName}/index.theme"
                sed -i 's/^Comment=.*/Comment=Matugen generated Papirus icon theme/' "$out/share/icons/${matugenIconThemeName}/index.theme"
                sed -i 's/^Inherits=.*/Inherits=${
                    if mode == "dark" then "breeze-dark" else "breeze"
                },hicolor/' "$out/share/icons/${matugenIconThemeName}/index.theme"

                theme_dir="$out/share/icons/${matugenIconThemeName}"
                for size in 16x16 22x22 24x24 32x32 48x48 64x64; do
                  for prefix in folder user; do
                    for file_path in "$theme_dir/$size/places/$prefix-${papirusFolderColor}"{,-*}.svg; do
                      [ -f "$file_path" ] || continue
                      [ ! -L "$file_path" ] || continue
                      file_name="''${file_path##*/}"
                      dir_name="''${file_path%/*}"
                      symlink_name="''${file_name/-${papirusFolderColor}/}"
                      symlink_path="$dir_name/$symlink_name"
                      ln -sf "$file_name" "$symlink_path"
                    done
                  done
                done
            '';
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
                brave.enable = mkIntegrationEnable "Brave";
                btop.enable = mkIntegrationEnable "btop";
                chrome.enable = mkIntegrationEnable "Google Chrome";
                chromium.enable = mkIntegrationEnable "Chromium";
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
        icon_theme = lib.mkOption {
            type = lib.types.attrs;
            readOnly = true;
            description = "Resolved icon theme package and name used by desktop theming modules.";
        };
    };

    config.biryani.theming.palette = {
        active = if cfg.enable then matugenPalette else staticPalette;
        matugen = if cfg.enable then matugenPalette else staticPalette;
        static = staticPalette;
    };

    config.biryani.theming.icon_theme = {
        package = if cfg.enable then matugenIconTheme else pkgs.papirus-icon-theme;
        name = if cfg.enable then matugenIconThemeName else "Papirus-Dark";
        papirus_folder_color = if cfg.enable then papirusFolderColor else "blue";
        papirus_base_name = if cfg.enable then papirusBaseThemeName else "Papirus-Dark";
    };
}
