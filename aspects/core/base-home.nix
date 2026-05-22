{
    config,
    inputs,
    lib,
    pkgs,
    biryani,
    ...
}:
{
    imports = [ ./home-modules.nix ];

    config =
        let
            biryani_browsers = biryani.programs.browsers;
            biryani_editors = biryani.programs.editors;
            biryani_terminals = biryani.programs.terminals;
            biryani_theming = config.biryani.theming;
            biryani_config = { inherit biryani; };
            palette = biryani_theming.palette.active;
            batTheme = pkgs.writeTextDir "matugen.tmTheme" ''
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                <dict>
                  <key>name</key><string>matugen</string>
                  <key>settings</key>
                  <array>
                    <dict><key>settings</key><dict><key>background</key><string>${palette.surface}</string><key>foreground</key><string>${palette.on_surface}</string><key>caret</key><string>${palette.primary}</string><key>selection</key><string>${palette.primary_container}</string></dict></dict>
                    <dict><key>scope</key><string>comment</string><key>settings</key><dict><key>foreground</key><string>${palette.outline}</string><key>fontStyle</key><string>italic</string></dict></dict>
                    <dict><key>scope</key><string>string</string><key>settings</key><dict><key>foreground</key><string>${palette.secondary}</string></dict></dict>
                    <dict><key>scope</key><string>constant.numeric, constant.language</string><key>settings</key><dict><key>foreground</key><string>${palette.tertiary}</string></dict></dict>
                    <dict><key>scope</key><string>keyword, storage</string><key>settings</key><dict><key>foreground</key><string>${palette.primary}</string></dict></dict>
                    <dict><key>scope</key><string>entity.name.function, support.function</string><key>settings</key><dict><key>foreground</key><string>${palette.primary}</string></dict></dict>
                    <dict><key>scope</key><string>entity.name.type, support.type</string><key>settings</key><dict><key>foreground</key><string>${palette.tertiary}</string></dict></dict>
                    <dict><key>scope</key><string>variable, identifier</string><key>settings</key><dict><key>foreground</key><string>${palette.on_surface}</string></dict></dict>
                    <dict><key>scope</key><string>invalid</string><key>settings</key><dict><key>foreground</key><string>${palette.on_error}</string><key>background</key><string>${palette.error}</string></dict></dict>
                  </array>
                </dict>
                </plist>
            '';

            browsers_meta = import ./metadata/programs/browsers.nix { inherit pkgs; };
            editors_meta = import ./metadata/programs/editors.nix {
                config = biryani_config;
                inherit inputs pkgs;
            };
            terminals_meta = import ./metadata/programs/terminals.nix {
                config = biryani_config;
                inherit inputs pkgs;
            };
        in
        {
            programs.home-manager.enable = true;

            home.stateVersion = "23.11";

            home.sessionVariables = {
                EDITOR = editors_meta."${biryani_editors.main}".cmd;
                VISUAL = editors_meta."${biryani_editors.main}".cmd;
                SUDO_EDITOR = editors_meta."${biryani_editors.main}".cmd;

                GOPATH = "${config.xdg.dataHome}/golang";
            }
            // lib.optionalAttrs biryani_terminals.enable {
                TERMINAL = terminals_meta."${biryani_terminals.main}".cmd;
                BROWSER = browsers_meta."${biryani_browsers.main}".cmd;
            };

            programs.bat = {
                enable = true;
                config.theme =
                    if biryani_theming.matugen.integrations.bat.enable then "matugen" else "gruvbox-dark";
                themes.matugen.src = batTheme;
                themes.matugen.file = "matugen.tmTheme";
            };

            programs.btop = {
                enable = true;
                package = pkgs.btop.override { cudaSupport = true; };
                settings.color_theme =
                    if biryani_theming.matugen.integrations.btop.enable then "matugen" else "Default";
            };

            xdg.configFile."btop/themes/matugen.theme" =
                lib.mkIf biryani_theming.matugen.integrations.btop.enable
                    {
                        text = ''
                            theme[main_bg]="${palette.surface}"
                            theme[main_fg]="${palette.on_surface}"
                            theme[title]="${palette.primary}"
                            theme[hi_fg]="${palette.primary}"
                            theme[selected_bg]="${palette.primary_container}"
                            theme[selected_fg]="${palette.on_primary_container}"
                            theme[inactive_fg]="${palette.outline}"
                            theme[graph_text]="${palette.on_surface}"
                            theme[meter_bg]="${palette.surface_container_highest}"
                            theme[proc_misc]="${palette.tertiary}"
                            theme[cpu_box]="${palette.primary}"
                            theme[mem_box]="${palette.secondary}"
                            theme[net_box]="${palette.tertiary}"
                            theme[proc_box]="${palette.outline}"
                            theme[div_line]="${palette.outline_variant}"
                            theme[temp_start]="${palette.secondary}"
                            theme[temp_mid]="${palette.primary}"
                            theme[temp_end]="${palette.error}"
                            theme[cpu_start]="${palette.primary_container}"
                            theme[cpu_mid]="${palette.primary}"
                            theme[cpu_end]="${palette.error}"
                            theme[free_start]="${palette.surface_container_high}"
                            theme[free_mid]="${palette.secondary_container}"
                            theme[free_end]="${palette.secondary}"
                            theme[cached_start]="${palette.surface_container_high}"
                            theme[cached_mid]="${palette.tertiary_container}"
                            theme[cached_end]="${palette.tertiary}"
                            theme[available_start]="${palette.surface_container_high}"
                            theme[available_mid]="${palette.primary_container}"
                            theme[available_end]="${palette.primary}"
                            theme[used_start]="${palette.surface_container_high}"
                            theme[used_mid]="${palette.error_container}"
                            theme[used_end]="${palette.error}"
                            theme[download_start]="${palette.surface_container_high}"
                            theme[download_mid]="${palette.primary_container}"
                            theme[download_end]="${palette.primary}"
                            theme[upload_start]="${palette.surface_container_high}"
                            theme[upload_mid]="${palette.secondary_container}"
                            theme[upload_end]="${palette.secondary}"
                        '';
                    };

            home.packages = with pkgs; [
                dust
                fd
                nh
                nixd
                ripgrep
            ];

            home.preferXdgDirectories = true;
            xdg = {
                enable = true;
                userDirs = {
                    enable = true;
                    createDirectories = true;
                    setSessionVariables = true;
                    desktop = "${config.home.homeDirectory}/media/desktop";
                    documents = "${config.home.homeDirectory}/media/documents";
                    download = "${config.home.homeDirectory}/media/downloads";
                    music = "${config.home.homeDirectory}/media/music";
                    publicShare = "${config.home.homeDirectory}/media/public";
                    templates = "${config.home.homeDirectory}/media/templates";
                    videos = "${config.home.homeDirectory}/media/videos";
                    pictures = "${config.home.homeDirectory}/media/pictures";
                    projects = "${config.home.homeDirectory}/media/projects";
                };
            };
        };
}
