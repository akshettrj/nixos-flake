{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    options.biryani = {
        programs.terminals.ghostty = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable Ghostty through Home Manager.";
            };

            use_official_package = lib.mkOption {
                type = lib.types.bool;
                description = "Use the Ghostty package from the Ghostty flake input instead of nixpkgs.";
            };

            background_opacity = lib.mkOption {
                type = lib.types.number;
                description = "Background opacity used by Ghostty.";
            };

            background_blur = lib.mkOption {
                type = lib.types.bool;
                description = "Enable Ghostty background blur.";
            };
        };

    };

    config =
        let
            biryani_shells = config.biryani.shells;
            biryani_terminals = config.biryani.programs.terminals;
            biryani_theming = config.biryani.theming;
            palette =
                if biryani_theming.matugen.integrations.ghostty.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;

            terminals_meta = import ../core/metadata/programs/terminals.nix { inherit config inputs pkgs; };
        in
        lib.mkIf (biryani_terminals.enable && biryani_terminals.ghostty.enable) {
            programs.ghostty = {
                enable = true;

                package = terminals_meta.ghostty.pkg;

                enableBashIntegration = lib.mkIf biryani_shells.bash.enable true;
                enableZshIntegration = lib.mkIf biryani_shells.zsh.enable true;
                enableFishIntegration = lib.mkIf biryani_shells.fish.enable true;

                settings = {
                    font-family = "${biryani_theming.fonts.main.name}";
                    window-decoration = false;
                    alpha-blending = "linear-corrected";
                    background-opacity = biryani_terminals.ghostty.background_opacity;
                    background-blur = biryani_terminals.ghostty.background_blur;
                    background = palette.surface;
                    foreground = palette.on_surface;
                    cursor-color = palette.primary;
                    cursor-text = palette.on_primary;
                    selection-background = palette.primary_container;
                    selection-foreground = palette.on_primary_container;
                    palette = [
                        "0=${palette.base16.base00}"
                        "1=${palette.base16.base08}"
                        "2=${palette.base16.base0b}"
                        "3=${palette.base16.base0a}"
                        "4=${palette.base16.base0d}"
                        "5=${palette.base16.base0e}"
                        "6=${palette.base16.base0c}"
                        "7=${palette.base16.base05}"
                        "8=${palette.base16.base03}"
                        "9=${palette.base16.base08}"
                        "10=${palette.base16.base0b}"
                        "11=${palette.base16.base0a}"
                        "12=${palette.base16.base0d}"
                        "13=${palette.base16.base0e}"
                        "14=${palette.base16.base0c}"
                        "15=${palette.base16.base07}"
                    ];
                };
            };
        };
}
