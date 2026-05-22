{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    options.biryani = {
        programs.terminals.wezterm = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable WezTerm through Home Manager.";
            };

            font_size = lib.mkOption {
                type = lib.types.number;
                description = "Font size used by WezTerm.";
            };

            use_official_package = lib.mkOption {
                type = lib.types.bool;
                description = "Use the WezTerm package from the WezTerm flake input instead of nixpkgs.";
            };

            enable_wayland = lib.mkOption {
                type = lib.types.bool;
                description = "Enable WezTerm Wayland support.";
            };
        };

    };

    config =
        let
            biryani_shells = config.biryani.shells;
            biryani_terminals = config.biryani.programs.terminals;
            biryani_theming = config.biryani.theming;
            palette =
                if biryani_theming.matugen.integrations.wezterm.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;

            terminals_meta = import ../core/metadata/programs/terminals.nix { inherit config inputs pkgs; };
        in
        lib.mkIf (biryani_terminals.enable && biryani_terminals.wezterm.enable) {
            programs.wezterm = {
                enable = true;

                package = terminals_meta.wezterm.pkg;

                enableBashIntegration = lib.mkIf biryani_shells.bash.enable true;
                enableZshIntegration = lib.mkIf biryani_shells.zsh.enable true;

                extraConfig =
                    # lua
                    ''
                        local wezterm = require("wezterm");

                        local config = {};

                        if wezterm.config_builder then
                            config = wezterm.config_builder()
                        end

                        config.font = wezterm.font_with_fallback({
                            "${biryani_theming.fonts.main.name}",
                            ${lib.strings.concatStringsSep ",\n" (
                                map (font: ''"${font.name}"'') (biryani_theming.fonts.backups)
                            )}
                        })
                        config.font_size = ${toString (biryani_terminals.wezterm.font_size)}

                        config.window_frame = {
                            font = wezterm.font_with_fallback({
                                "${biryani_theming.fonts.main.name}",
                                ${lib.strings.concatStringsSep ",\n" (
                                    map (font: ''"${font.name}"'') (biryani_theming.fonts.backups)
                                )}
                            }),
                            font_size = ${toString (biryani_terminals.wezterm.font_size)},
                        }

                        config.colors = {
                            foreground = "${palette.on_surface}",
                            background = "${palette.surface}",
                            cursor_bg = "${palette.primary}",
                            cursor_fg = "${palette.on_primary}",
                            cursor_border = "${palette.primary}",
                            selection_bg = "${palette.primary_container}",
                            selection_fg = "${palette.on_primary_container}",
                            ansi = {
                                "${palette.base16.base00}",
                                "${palette.base16.base08}",
                                "${palette.base16.base0b}",
                                "${palette.base16.base0a}",
                                "${palette.base16.base0d}",
                                "${palette.base16.base0e}",
                                "${palette.base16.base0c}",
                                "${palette.base16.base05}",
                            },
                            brights = {
                                "${palette.base16.base03}",
                                "${palette.base16.base08}",
                                "${palette.base16.base0b}",
                                "${palette.base16.base0a}",
                                "${palette.base16.base0d}",
                                "${palette.base16.base0e}",
                                "${palette.base16.base0c}",
                                "${palette.base16.base07}",
                            },
                        }
                        config.hide_tab_bar_if_only_one_tab = false
                        config.window_background_opacity = 0.95
                        config.audible_bell = "Disabled"
                        config.check_for_updates = false
                        config.hide_mouse_cursor_when_typing = false

                        config.enable_wayland = ${if biryani_terminals.wezterm.enable_wayland then "true" else "false"}

                        config.front_end = "WebGpu"

                        return config
                    '';
            };
        };
}
