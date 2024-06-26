{ config, inputs, pkgs, ... }:

{
    imports = [
        ./hardware-configuration.nix
        ../../common/nixos/configuration.nix

        inputs.home-manager.nixosModules.home-manager
    ];

    propheci = {
        system = {
            hostname = "oracleamd2";
            time_zone = "EST";
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
            nvidia.enable = false;
        };

        # Various Services
        services = {
            printing.enable = false;
            firewall = {
                enable = true;
                tcp_ports = [22];
                udp_ports = [];
            };
            pipewire.enable = false;
            openssh = {
                server = {
                    enable = true;
                    ports = [22];
                    password_authentication = false;
                    root_login = "no";
                    x11_forwarding = false;
                    public_keys = [ ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZwkmaaZ+i9usypmporvPyirpVCqoELZ1xa8HCTWBCRzFcg2Ym/S6TtISJI0uv3lV4AuosYWU9pNj20u17UUZpf8L6PbRRfdchKoll4ZdkAg+BU8TTlFAIuKexW1skq+TvaV1S4cFPY28iHhzp61EtfILxHwgRf3OZUM4UkoNoVxIkPAa+D3gS4SR+8JuhD+lcNvz7IMJ4D2b6+u/9u0fe9bBJdzRC/larHiY5Pi03p9ewnCAw3QndYZ7fF9cR9tIlvT8zXVwzW1DmURjKW3q6JfBkhQYgtDA8jBEjtgi9haqo+qWYsp2nFu7grikP1/Fb6nCokphuroLUwdTOELAr ssh-key-2022-10-03'' ];
                };
            };
            tailscale.enable = true;
            xdg_portal.enable = false;
        };

        # Nix/NixOS specific
        nix = {
            garbage_collection.enable = true;
            nix_community_cache = true;
            hyprland_cache = true;
            helix_cache = true;
        };

        # Appearance
        theming.enable = false;

        dev = {
            git = {
                enable = true;
                user = {
                    name = "Akshett Rai Jindal";
                    email = "jindalakshett@gmail.com";
                };
                delta.enable = true;
                default_branch = "main";
            };
        };

        programs = {
            media = {
                audio = {
                    mpd = {
                        enable = false;
                        ncmpcpp.enable = false;
                    };
                };
            };
            social_media = {
                telegram.enable = false;
                discord.enable = false;
                slack.enable = false;
                beeper.enable = false;
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
                    nightly = true;
                };
            };
            terminals.enable = false;
            browsers.enable = false;
            file_explorers = {
                main = "lf";
                backup = "yazi";
                lf.enable = true;
                yazi.enable = true;
            };
            launchers.enable = false;
        };

        shells = {
            main = "zsh";
            aliases = import (../../common/home-manager/modules/shells/aliases.nix);
            bash.enable = true;
            fish.enable = false;
            nushell.enable = false;
            zsh.enable = true;

            eza.enable = true;
            starship.enable = true;
            zoxide.enable = true;
        };

        desktop_environments.enable = false;
    };

    # DO NOT DELETE
    system.stateVersion = "23.11";

    home-manager = {
        extraSpecialArgs = { inherit inputs; inherit pkgs; propheci = config.propheci; };
        users = {
            "${config.propheci.user.username}" = { propheci, ... }: {
                imports = [
                    ../../common/home-manager/configuration.nix
                ];

                propheci = propheci;
            };
        };
    };
}
