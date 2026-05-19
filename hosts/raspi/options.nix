{ inputs, pkgs, ... }:
{
    biryani = {
        system = {
            hostname = "raspi";
            time_zone = "Asia/Kolkata";
            swap_devices = [
                {
                    device = "/var/lib/swapfile";
                    size = 6 * 1024;
                }
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
            nvidia.enable = false;
            graphics.enable = true;
            iphone.enable = false;
        };

        # Various Services
        services = {
            virtualisation.enable = false;
            nginx.enable = false;
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
                    x11_forwarding = true;
                };
            };
            tailscale.enable = true;
            xdg_portal.enable = false;
            telegram_bot_api.enable = false;
            openvpn.enable = false;
        };

        # Nix/NixOS specific
        nix = {
            garbage_collection.enable = true;
            nix_community_cache = true;
            hyprland_cache = true;
            helix_cache = true;
            wezterm_cache = false;
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
            wallpaper = "${inputs.wallpapers}/panda-2-1920×1080.png";
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
            media = {
                enable = true;
                services.mpris.enable = true;
                audio = {
                    mpd = {
                        enable = false;
                        ncmpcpp.enable = false;
                    };
                };
                video = {
                    mpv.enable = true;
                    vlc.enable = false;
                    stremio.enable = false;
                    jellyfin.enable = false;
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
            editors = {
                main = "neovim";
                backup = "helix";
                neovim = {
                    enable = true;
                    nightly = true;
                };
                helix = {
                    enable = true;
                    nightly = false;
                };
                zeditor.enable = false;
                emacs.enable = false;
            };
            terminals = {
                enable = true;
                main = "wezterm";
                backup = "alacritty";
                wezterm = {
                    enable = true;
                    use_official_package = false;
                    font_size = 10;
                    enable_wayland = false;
                };
                alacritty = {
                    enable = true;
                    font_size = 11;
                };
                ghostty.enable = false;
            };
            browsers = {
                enable = true;
                main = "brave";
                brave = {
                    enable = true;
                    cmd_args = [ ];
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
                swaylock.enable = true;
                hyprlock = {
                    enable = false;
                    background_image = "${inputs.wallpapers}/gta-5-wallpaper-1920×1080.jpg";
                };
            };
            clipboard_managers = {
                enable = true;
                copyq.enable = true;
            };
            notification_daemons = {
                enable = true;
                dunst = {
                    enable = true;
                    font_size = 10;
                };
            };
            bars = {
                enable = true;
                waybar = {
                    enable = true;
                    use_official_package = false;
                    heights = 28;
                    font_size = 12;
                    separator_size = 18;
                    icon_size = 15;
                    tray_spacing = 8;
                    is_laptop = true;
                    systemd_target = "hyprland-session.target";
                };
            };
            extra_utilities = {
                drivedlgo.enable = true;
                rclone.enable = true;
            };
        };

        shells = {
            main = "zsh";
            aliases = import ../../aspects/shell/aliases.nix;
            bash.enable = true;
            fish.enable = false;
            nushell.enable = false;
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
                screenlock = "swaylock";
                screenshot_tool = "hyprshot";
                clipboard_manager = "copyq";
                monitors = [ ];
            };
        };
    };
}
