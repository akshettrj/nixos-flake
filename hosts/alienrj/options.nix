{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    services.awcc.enable = true;

    biryani = rec {
        system = {
            hostname = "alienrj";
            time_zone = "Asia/Kolkata";
            swap_devices = [
                # {
                #   device = "/var/lib/swapfile";
                #   size = 6 * 1024;
                # }
            ];
        };
        user = {
            username = "akshettrj";
            homedir = "/home/akshettrj";
        };
        security = {
            sudo_without_password = true;
            polkit.enable = true;
        };

        hardware = {
            bluetooth.enable = true;
            pulseaudio.enable = false;
            nvidia = {
                enable = true;
                package = config.boot.kernelPackages.nvidiaPackages.latest;
                prime = {
                    enable = true;
                    intelBusId = "PCI:00:02:0";
                    nvidiaBusId = "PCI:01:00:0";
                };
            };
            graphics.enable = false;
            iphone = {
                enable = true;
                usbmuxd_package = pkgs.usbmuxd;
            };
        };

        # Various Services
        services = {
            virtualisation = {
                enable = true;
                docker = {
                    enable = true;
                    rootless = true;
                };
                containers = {
                    enable = true;
                    backend = "docker";
                };
            };
            printing.enable = false;
            firewall = {
                enable = true;
                tcp_ports = [ 22 ];
                udp_ports = [ ];
            };
            pipewire.enable = true;
            openssh = {
                server = {
                    enable = true;
                    ports = [ 22 ];
                    password_authentication = true;
                    root_login = "prohibit-password";
                    x11_forwarding = false;
                };
            };
            tailscale.enable = true;
            xdg_portal.enable = false;
            telegram_bot_api = {
                enable = true;
                port = 8082;
                data_dir = user.homedir + "/.local/share/telegram-bot-api";
            };
            nginx.enable = false;
            openvpn.enable = false;
            sync = {
                enable = true;
                devices = {
                    oracleamperehyd.id = "NQU5OGN-WPJA7R6-S5LDKEF-DBGMSI7-4CO45B5-XHDG65B-BOLUCLD-YTS2MAZ";
                    raspi.id = "NJURPXN-EV5J6RQ-CAKG53B-7GETTR3-UFGJBEQ-2GSYGIF-P27KQ46-EHNFKQQ";
                };
                folders.music = {
                    path = "/home/akshettrj/media/music";
                    devices = [
                        "oracleamperehyd"
                        "raspi"
                    ];
                };
            };
        };

        # Nix/NixOS specific
        nix = {
            garbage_collection.enable = true;
            nix_community_cache = true;
            hyprland_cache = true;
            helix_cache = true;
            wezterm_cache = true;
        };

        # Appearance
        theming = {
            enable = true;
            fonts = {
                nerdfonts = [
                    "jetbrains-mono"
                    "iosevka"
                ];
                main = {
                    name = "Iosevka NF";
                    size = 13;
                };
                backups = [
                    {
                        name = "JetBrainsMono NF";
                        size = 13;
                    }
                ];
            };
            gtk = true;
            qt = true;
            cursor = {
                package = pkgs.whitesur-cursors;
                name = "WhiteSur-cursors";
                size = 26;
            };
            minimum_brightness = 40;
            wallpaper = "${inputs.wallpapers}/project_hail_mary/astrophage.webp";
            matugen = {
                enable = true;
                scheme = "scheme-content";
                mode = "dark";
                integrations = {
                    brave.enable = false;
                    chrome.enable = false;
                    chromium.enable = false;
                    # ghostty.enable = true;
                };
            };
        };

        dev = {
            git = {
                enable = true;
                user = {
                    name = "Akshett Rai Jindal";
                };
                delta.enable = true;
                default_branch = "main";
            };
            direnv.enable = true;
            cachix.enable = true;
        };

        programs = {
            vpn.mullvad.enable = true;
            gaming.enable = false;
            ai = {
                enable = true;
                mcpServers = {
                    personal_py = {
                        command = "${
                            inputs.mcp_python.packages.${pkgs.stdenv.hostPlatform.system}.default
                        }/bin/personal-mcp";
                        args = [ ];
                        trust = true;
                    };
                };
                skills = import ../../aspects/ai/skills.nix { inherit inputs; };
                cursor.enable = true;
                codex = {
                    enable = true;
                    mcpServers = null;
                };
                claude-code = {
                    enable = true;
                    mcpServers = null;
                };
                gemini = {
                    enable = true;
                    mcpServers = null;
                };
                ollama = {
                    enable = false;
                    acceleration = "cuda";
                };
            };
            media = {
                enable = true;
                services.mpris.enable = true;
                audio = {
                    mpd = {
                        enable = true;
                        ncmpcpp.enable = true;
                    };
                };
                video = {
                    mpv.enable = true;
                    vlc.enable = false;
                    stremio.enable = false;
                    jellyfin.enable = true;
                };
                picture = {
                    feh.enable = true;
                    sxiv.enable = true;
                };
                documents = {
                    zathura = {
                        enable = true;
                        useMupdf = true;
                    };
                    sioyek.enable = true;
                };
            };
            extra_utilities = {
                drivedlgo.enable = false;
                librepods.enable = false;
                pleezer.enable = false;
                taggie.enable = false;
                typst.enable = true;
                ffmpeg.enable = true;
                rclone.enable = true;
                obs.enable = true;
                odesli.enable = true;
                ueberzugpp.enable = true;
                yt-dlp.enable = true;
                gh.enable = true;
                obsidian.enable = true;
            };
            social_media = {
                telegram.enable = true;
                discord.enable = true;
                beeper.enable = false;
                teams.enable = true;
                zulip.enable = false;
            };
            editors = {
                main = "neovim";
                backup = "helix";
                neovim = {
                    enable = true;
                    nightly = false;
                };
                helix = {
                    enable = true;
                    nightly = true;
                };
                zeditor.enable = false;
                emacs.enable = true;
            };
            terminals = {
                enable = true;
                main = "ghostty";
                backup = "alacritty";
                wezterm = {
                    enable = true;
                    use_official_package = true;
                    font_size = 10;
                    enable_wayland = false;
                };
                alacritty = {
                    enable = true;
                    font_size = 11;
                };
                ghostty = {
                    enable = true;
                    use_official_package = false;
                    background_opacity = 0.95;
                    background_blur = true;
                };
            };
            browsers = {
                enable = true;
                main = "brave";
                brave = {
                    enable = true;
                    cmd_args = [
                        "--ozone-platform=wayland"
                        "--use-gl=egl"
                        "--enable-features=VaapiVideoDecodeLinuxGL,VaapiIgnoreDriverChecks"
                        "--ignore-gpu-blocklist"
                        "--enable-gpu-rasterization"
                    ];
                };
                firefox.enable = true;
                chromium.enable = false;
                chrome.enable = false;
            };
            file_explorers = {
                main = "lf";
                backup = "yazi";
                lf.enable = true;
                yazi.enable = true;
            };
            launchers = {
                enable = true;
                bemenu = {
                    enable = true;
                    font_size = 13;
                };
            };
            screenshot_tools = {
                enable = true;
                flameshot.enable = true;
                wayshot.enable = true;
                shotman.enable = true;
                hyprshot.enable = true;
            };
            screenlocks = {
                enable = true;
                swaylock.enable = false;
                hyprlock = {
                    enable = true;
                    font_size = 16;
                };
            };
            clipboard_managers = {
                enable = true;
                copyq.enable = true;
            };
            notification_daemons = {
                enable = true;
                dunst = {
                    enable = false;
                    font_size = 10;
                };
                swaync.enable = true;
            };
            bars = {
                enable = true;
                quickshell = {
                    enable = false;
                    use_official_package = false;
                    enabled_configs = [
                        "hello-world"
                        "multi-monitor-clock"
                    ];
                    systemd_target = "hyprland-session.target";
                };
                waybar = {
                    enable = true;
                    use_official_package = false;
                    heights = 30;
                    font_size = 14;
                    separator_size = 20;
                    icon_size = 16;
                    tray_spacing = 9;
                    is_laptop = true;
                    systemd_target = "hyprland-session.target";
                };
            };
        };

        shells = {
            main = "zsh";
            aliases = import ../../aspects/shell/aliases.nix;
            bash.enable = true;
            fish.enable = false;
            nushell.enable = true;
            zsh.enable = true;

            eza.enable = true;
            starship.enable = true;
            zoxide.enable = true;
        };

        desktop_environments = {
            enable = true;
            defaults = {
                "/dev/tty1" = "hyprland";
            };
            wayland.enable = true;
            hyprland = {
                enable = true;
                use_official_packages = false;
                scroll_factor = 0.2;
                launcher = "bemenu";
                screenlock = "hyprlock";
                screenshot_tool = "hyprshot";
                clipboard_manager = "copyq";
                monitors = [
                    {
                        enabled = true;
                        name = "eDP-1";
                        width = 2560;
                        height = 1600;
                        refresh_rate = 165;
                        x = 0;
                        y = 0;
                        additional_settings = "1.33";
                        workspaces = lib.range 1 10;
                    }
                    {
                        enabled = true;
                        name = "HDMI-A-1";
                        width = 1920;
                        height = 1080;
                        refresh_rate = 60;
                        # The x value is 2560 / 1.6 (width / scaling factor)
                        x = 1924;
                        y = 0;
                        additional_settings = "1";
                        workspaces = lib.range 11 20;
                    }
                ];
            };
        };
    };
}
