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
            biryani_deskenvs = biryani.desktop_environments;
            biryani_editors = biryani.programs.editors;
            biryani_services = biryani.services;
            biryani_terminals = biryani.programs.terminals;
            biryani_user = biryani.user;
            biryani_config = { inherit biryani; };

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
            biryani = {
                dev = {
                    cachix.enable = biryani.dev.cachix.enable;
                    direnv.enable = biryani.dev.direnv.enable;
                    git = biryani.dev.git;
                };

                hardware.bluetooth.enable = biryani.hardware.bluetooth.enable;
                hardware.nvidia.enable = biryani.hardware.nvidia.enable;
                hardware.pulseaudio.enable = biryani.hardware.pulseaudio.enable;

                programs = {
                    ai = {
                        enable = biryani.programs.ai.enable or false;
                    }
                    // lib.optionalAttrs (biryani.programs.ai.enable or false) {
                        codex = biryani.programs.ai.codex;
                        cursor = biryani.programs.ai.cursor;
                        gemini = biryani.programs.ai.gemini;
                        mcpServers = biryani.programs.ai.mcpServers;
                        ollama = biryani.programs.ai.ollama;
                        skills = biryani.programs.ai.skills;
                    };

                    browsers = {
                        inherit (biryani_browsers) enable;
                        brave = biryani_browsers.brave;
                        chrome = biryani_browsers.chrome;
                        chromium = biryani_browsers.chromium;
                        firefox.enable = biryani_browsers.firefox.enable;
                    };

                    bars = {
                        enable = biryani.programs.bars.enable;
                        quickshell.enable = biryani.programs.bars.quickshell.enable;
                    }
                    // lib.optionalAttrs biryani.programs.bars.enable { waybar = biryani.programs.bars.waybar; }
                    // lib.optionalAttrs (biryani.programs.bars.enable && biryani.programs.bars.quickshell.enable) {
                        quickshell = biryani.programs.bars.quickshell;
                    };

                    clipboard_managers = biryani.programs.clipboard_managers;
                    editors = {
                        helix = biryani.programs.editors.helix;
                        neovim = biryani.programs.editors.neovim;
                        zeditor = biryani.programs.editors.zeditor;
                    };
                    file_explorers = biryani.programs.file_explorers;
                    launchers = biryani.programs.launchers;
                    media = biryani.programs.media;
                    notification_daemons = biryani.programs.notification_daemons;
                    screenlocks = biryani.programs.screenlocks;
                    screenshot_tools = biryani.programs.screenshot_tools;
                    social_media = biryani.programs.social_media;
                    terminals = biryani.programs.terminals;
                };

                services.pipewire.enable = biryani.services.pipewire.enable;
                system.time_zone = biryani.system.time_zone;

                shells = {
                    aliases = biryani.shells.aliases;
                    bash.enable = biryani.shells.bash.enable;
                    eza.enable = biryani.shells.eza.enable;
                    fish.enable = biryani.shells.fish.enable;
                    main = biryani.shells.main;
                    nushell.enable = biryani.shells.nushell.enable;
                    starship.enable = biryani.shells.starship.enable;
                    zoxide.enable = biryani.shells.zoxide.enable;
                    zsh.enable = biryani.shells.zsh.enable;
                };

                desktop_environments = {
                    enable = biryani.desktop_environments.enable;
                }
                // lib.optionalAttrs biryani.desktop_environments.enable {
                    defaults = biryani.desktop_environments.defaults;
                    hyprland = biryani.desktop_environments.hyprland;
                    wayland = biryani.desktop_environments.wayland;
                };

                theming.fonts = {
                    main = {
                        name = biryani.theming.fonts.main.name;
                        size = biryani.theming.fonts.main.size;
                    };
                    backups = biryani.theming.fonts.backups;
                };
                theming.cursor = biryani.theming.cursor;
                theming.enable = biryani.theming.enable;
                theming.gtk = biryani.theming.gtk;
                theming.minimum_brightness = biryani.theming.minimum_brightness;
                theming.qt = biryani.theming.qt;
                theming.wallpaper = biryani.theming.wallpaper;
            };

            programs.home-manager.enable = true;

            home.username = biryani_user.username;
            home.homeDirectory = biryani_user.homedir;
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

            home.packages = with pkgs; [
                bat
                (btop.override { cudaSupport = true; })
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
                portal = lib.mkIf biryani_services.xdg_portal.enable {
                    enable = true;
                    config = {
                        common.default = [ "gtk" ];
                        hyprland.default = [
                            "gtk"
                            "hyprland"
                        ];
                    };
                    extraPortals = [
                        pkgs.xdg-desktop-portal-gtk
                    ]
                    ++ lib.optionals biryani_deskenvs.hyprland.enable [
                        (
                            if biryani_deskenvs.hyprland.use_official_packages then
                                inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".xdg-desktop-portal-hyprland
                            else
                                pkgs.xdg-desktop-portal-hyprland
                        )
                    ];
                };
                mimeApps = {
                    enable = true;
                    associations = {
                        added = {
                            "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
                            "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
                            "x-scheme-handler/msteams" = [ "teams-for-linux.desktop" ];
                        };
                    };
                    defaultApplications =
                        let
                            image_desktop_entries = [
                                "sxiv.desktop"
                                "feh.desktop"
                            ];
                        in
                        {
                            "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
                            "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
                            "x-scheme-handler/msteams" = [ "teams-for-linux.desktop" ];
                            "application/pdf" = [
                                "sioyek.desktop"
                                "org.pwmt.zathura-pdf-mupdf.desktop"
                            ];
                            "image/png" = image_desktop_entries;
                            "image/jpeg" = image_desktop_entries;
                            "image/webp" = image_desktop_entries;
                        };
                };
            };
        };
}
