{
    config,
    inputs,
    lib,
    pkgs,
    pkgs_unstable,
    pkgs_stable,
    use_stable_pkgs,
    ...
}:
{
    imports = [
        (lib.mkAliasOptionModule [ "propheci" ] [ "biryani" ])
        ./options.nix
        ./system-modules.nix

        inputs.nix-index-database.nixosModules.nix-index # Cached database for nix-index
        inputs.nixpkgs.nixosModules.readOnlyPkgs
    ];

    options =
        let
            inherit (lib) mkOption types;

            known_shells = lib.attrNames (import ./metadata/programs/shells.nix { inherit pkgs; });
        in
        {
            biryani = {
                system = {
                    hostname = mkOption {
                        type = types.str;
                        example = "alienrj";
                        description = "Hostname assigned to this NixOS system.";
                    };

                    time_zone = mkOption {
                        type = types.str;
                        example = "Asia/Kolkata";
                        description = "IANA time zone used by this NixOS system.";
                    };

                    swap_devices = mkOption {
                        type = types.anything;
                        description = "Swap device declarations passed to NixOS swapDevices.";
                    };
                };

                user = {
                    username = mkOption {
                        type = types.str;
                        example = "akshettrj";
                        description = "Primary user account managed by this configuration.";
                    };

                    homedir = mkOption {
                        type = types.str;
                        example = "/home/akshettrj";
                        description = "Home directory for the primary user.";
                    };
                };

                security = {
                    sudo_without_password = mkOption {
                        type = types.bool;
                        description = "Allow the primary user to run sudo commands without a password.";
                    };

                    polkit.enable = mkOption {
                        type = types.bool;
                        description = "Enable polkit system authorization support.";
                    };
                };

                services.firewall = {
                    enable = mkOption {
                        type = types.bool;
                        description = "Enable the NixOS firewall with the configured allowed ports.";
                    };

                    tcp_ports = mkOption {
                        type = types.listOf types.port;
                        example = [ 22 ];
                        description = "TCP ports allowed through the host firewall.";
                    };

                    udp_ports = mkOption {
                        type = types.listOf types.port;
                        example = [ 6969 ];
                        description = "UDP ports allowed through the host firewall.";
                    };
                };

                nix = {
                    garbage_collection.enable = mkOption {
                        type = types.bool;
                        description = "Enable automatic Nix store garbage collection.";
                    };

                    nix_community_cache = mkOption {
                        type = types.bool;
                        description = "Trust and use the nix-community binary cache.";
                    };

                    hyprland_cache = mkOption {
                        type = types.bool;
                        description = "Trust and use the Hyprland binary cache.";
                    };

                    helix_cache = mkOption {
                        type = types.bool;
                        description = "Trust and use the Helix binary cache.";
                    };

                    wezterm_cache = mkOption {
                        type = types.bool;
                        description = "Trust and use the WezTerm binary cache.";
                    };
                };

                shells.main = mkOption {
                    type = types.enum known_shells;
                    description = "Default login shell for the primary user.";
                };
            };
        };

    config =
        let
            biryani_nix = config.biryani.nix;
            biryani_sec = config.biryani.security;
            biryani_shells = config.biryani.shells;
            biryani_system = config.biryani.system;
            biryani_services = config.biryani.services;
            biryani_user = config.biryani.user;

            shells_meta = import ./metadata/programs/shells.nix { inherit pkgs; };
        in
        {
            boot.loader.grub = {
                enable = true;
                device = "nodev";
                efiSupport = true;
                useOSProber = true;
            };

            boot.loader.efi.canTouchEfiVariables = true;

            boot.tmp = {
                useTmpfs = true;
                cleanOnBoot = true;
            };

            networking.hostName = biryani_system.hostname;
            networking.networkmanager = {
                enable = true;
                plugins = [ pkgs.networkmanager-openvpn ];
            };
            networking.firewall = lib.mkIf biryani_services.firewall.enable {
                enable = true;
                trustedInterfaces = [ "tailscale0" ];
                allowedUDPPorts = [ config.services.tailscale.port ] ++ biryani_services.firewall.udp_ports;
                allowedTCPPorts = [ config.services.tailscale.port ] ++ biryani_services.firewall.tcp_ports;
            };
            networking.nameservers = [
                "1.1.1.1"
                "1.0.0.1"
            ];

            time.timeZone = biryani_system.time_zone;

            swapDevices = biryani_system.swap_devices;

            users.users."${biryani_user.username}" = {
                isNormalUser = true;
                extraGroups = [
                    "networkmanager"
                    "wheel"
                ];
                initialPassword = "12345";
                shell = shells_meta."${biryani_shells.main}".pkg;
            };

            security.sudo.extraRules = lib.mkIf biryani_sec.sudo_without_password [
                {
                    users = [ "${biryani_user.username}" ];
                    commands = [
                        {
                            command = "ALL";
                            options = [ "NOPASSWD" ];
                        }
                    ];
                }
            ];

            security.polkit.enable = lib.mkIf biryani_sec.polkit.enable true;

            i18n.defaultLocale = "en_US.UTF-8";
            console = {
                font = "Lat2-Terminus16";
                useXkbConfig = true;
            };

            services.libinput.enable = true;
            services.xserver.xkb = {
                layout = "us";
                options = "caps:swapescape";
            };

            nix = {
                nixPath = [
                    "nixpkgs=${inputs.nixpkgs}"
                    "nixpkgs-master=${inputs.nixpkgs-master}"
                ];
                settings = {
                    experimental-features = "nix-command flakes pipe-operators";
                    auto-optimise-store = true;
                    extra-substituters = [
                        "https://propheci.cachix.org"
                        "https://watgbridge.cachix.org"
                    ]
                    ++ lib.optionals biryani_nix.nix_community_cache [ "https://nix-community.cachix.org" ]
                    ++ lib.optionals biryani_nix.hyprland_cache [ "https://hyprland.cachix.org" ]
                    ++ lib.optionals biryani_nix.helix_cache [ "https://helix.cachix.org" ]
                    ++ lib.optionals biryani_nix.wezterm_cache [ "https://wezterm.cachix.org" ];
                    extra-trusted-public-keys = [
                        "propheci.cachix.org-1:CwV87KMySX+rhW88NhTx2hRzdNltV497nhXvWswFGDc="
                        "watgbridge.cachix.org-1:KSfgmbSBvXQTpUnoCj21vST7zgwpy3SbNfk0/nesR1Y="
                    ]
                    ++ lib.optionals biryani_nix.nix_community_cache [
                        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                    ]
                    ++ lib.optionals biryani_nix.hyprland_cache [
                        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
                    ]
                    ++ lib.optionals biryani_nix.helix_cache [
                        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
                    ]
                    ++ lib.optionals biryani_nix.wezterm_cache [
                        "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
                    ];
                    trusted-users = [
                        "root"
                        "${biryani_user.username}"
                    ];
                    show-trace = true;
                    eval-cache = false;
                };
                gc = lib.mkIf biryani_nix.garbage_collection.enable {
                    automatic = true;
                    dates = "weekly";
                    options = "--delete-older-than 7d";
                };
            };

            nixpkgs.pkgs = if use_stable_pkgs then pkgs_stable else pkgs_unstable;

            environment.systemPackages = with pkgs; [
                # BASE + BASE-DEVEL
                binutils
                bzip2
                coreutils
                file
                findutils
                gawk
                gcc
                gitFull
                gnugrep
                gnused
                gnutar
                gzip
                iproute2
                iputils
                patch
                pciutils
                pkgconf
                procps
                psmisc
                shadow
                util-linux
                which
                xz

                # Essentials for root
                acpi
                curl
                htop
                jq
                lf
                lshw
                nix-output-monitor
                nixfmt
                tmux
                unzip
                vim
                vimv-rs
                wget
                wormhole-rs
                xdg-utils
                zellij
                zip

                # Extra utilities
                (inputs.home-manager.packages."${pkgs.stdenv.hostPlatform.system}".default)
            ];

            # Fights with nix-index
            programs.command-not-found.enable = false;
        };
}
