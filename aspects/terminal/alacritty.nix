{ config, lib, ... }:
{
    options.biryani = {
        programs.terminals = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable terminal emulator configuration through Home Manager.";
            };

            main = lib.mkOption {
                type = lib.types.str;
                description = "Primary terminal emulator name used by shared Home Manager session variables.";
            };

            backup = lib.mkOption {
                type = lib.types.str;
                description = "Fallback terminal emulator name.";
            };

            alacritty = {
                enable = lib.mkOption {
                    type = lib.types.bool;
                    description = "Enable Alacritty through Home Manager.";
                };

                font_size = lib.mkOption {
                    type = lib.types.number;
                    description = "Font size used by Alacritty.";
                };
            };
        };
    };

    config =
        let
            biryani_theming = config.biryani.theming;
            biryani_terminals = config.biryani.programs.terminals;
        in
        lib.mkIf (biryani_terminals.enable && biryani_terminals.alacritty.enable) {
            programs.alacritty = {
                enable = true;

                settings = {
                    colors = {
                        draw_bold_text_with_bright_colors = true;
                        bright = {
                            black = "#928374";
                            blue = "#83a598";
                            cyan = "#8ec07c";
                            green = "#b8bb26";
                            magenta = "#d3869b";
                            red = "#fb4934";
                            white = "#ebdbb2";
                            yellow = "#fabd2f";
                        };
                        normal = {
                            black = "#282828";
                            blue = "#458588";
                            cyan = "#689d6a";
                            green = "#98971a";
                            magenta = "#b16286";
                            red = "#cc241d";
                            white = "#a89984";
                            yellow = "#d79921";
                        };
                        primary = {
                            background = "#282828";
                            foreground = "#ebdbb2";
                        };
                    };
                    cursor = {
                        style = "Beam";
                        vi_mode_style = "Block";
                    };
                    debug = {
                        log_level = "Warn";
                        persistent_logging = false;
                        print_events = false;
                        render_timer = false;
                    };
                    font = {
                        size = biryani_terminals.alacritty.font_size;
                        bold = {
                            family = biryani_theming.fonts.main.name;
                            style = "Bold";
                        };
                        bold_italic = {
                            family = biryani_theming.fonts.main.name;
                            style = "Bold Italic";
                        };
                        italic = {
                            family = biryani_theming.fonts.main.name;
                            style = "Italic";
                        };
                        normal = {
                            family = biryani_theming.fonts.main.name;
                            style = "Regular";
                        };
                        offset = {
                            x = 0;
                            y = -1;
                        };
                    };
                    hints = {
                        enabled = [
                            {
                                command = "xdg-open";
                                post_processing = true;
                                regex = ''(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:|git@github.com:)[^\u0000-\u001F\u007F-<>"\\s{-}\\^⟨⟩`]+'';
                                binding = {
                                    key = "U";
                                    mods = "Control|Shift";
                                };
                                mouse = {
                                    enabled = true;
                                    mods = "None";
                                };
                            }
                        ];
                    };
                    mouse = {
                        hide_when_typing = true;
                        bindings = [
                            {
                                action = "Copy";
                                mouse = "Middle";
                            }
                        ];
                    };
                    selection = {
                        semantic_escape_chars = '',│`|:"' ()[]{}<>\t'';
                    };
                    window = {
                        decorations = "none";
                        dynamic_padding = true;
                        dynamic_title = true;
                        startup_mode = "Windowed";
                        class = {
                            general = "Alacritty";
                            instance = "alacritty";
                        };
                        padding = {
                            x = 10;
                            y = 4;
                        };
                        opacity = 0.95;
                    };
                    keyboard.bindings = [
                        {
                            action = "Copy";
                            key = "Y";
                            mods = "Alt";
                        }
                        {
                            action = "SpawnNewInstance";
                            key = 28;
                            mods = "Alt";
                        }
                        {
                            action = "IncreaseFontSize";
                            key = 13;
                            mods = "Alt";
                        }
                        {
                            action = "DecreaseFontSize";
                            key = 12;
                            mods = "Alt";
                        }
                    ];
                };
            };
        };
}
