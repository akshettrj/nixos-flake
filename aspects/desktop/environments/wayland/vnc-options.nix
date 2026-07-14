{ lib, ... }: {
    # Single source of truth for the VNC options. Imported into both module
    # graphs: the NixOS aggregator (aspects/desktop/options.nix) so hosts can set
    # values, and the home consumer (vnc.nix) so it can read them. home-bridge.nix
    # forwards the NixOS-set value into the home graph.
    options.biryani.services.vnc = {
        enable = lib.mkEnableOption "wayvnc VNC server for the Wayland session.";
        listen_address = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = ''
                Address wayvnc binds to. Defaults to localhost so the server is
                only reachable through SSH port forwarding and is never advertised
                on the network.
            '';
        };
        port = lib.mkOption {
            type = lib.types.port;
            default = 5900;
            description = "TCP port wayvnc listens on.";
        };
        systemd_target = lib.mkOption {
            type = lib.types.str;
            default = "hyprland-session.target";
            description = "Systemd user target the wayvnc service is bound to.";
        };

        auth = {
            enable = lib.mkEnableOption "password authentication and encryption for wayvnc";
            config_file = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                example = "/run/secrets/wayvnc-config";
                description = ''
                    Path to a wayvnc config file that supplies the authentication
                    settings, passed to wayvnc via `--config`. It must set at least
                    `enable_auth=true`, a `password=<secret>`, and the encryption keys
                    (either `rsa_private_key_file=<path>` for RSA-AES, or both
                    `certificate_file=<path>` and `private_key_file=<path>` for TLS);
                    `username=<name>` is optional.

                    This is a string, not a Nix path, so the referenced file is never
                    copied into the world-readable Nix store: point it at a secret
                    managed elsewhere (the private secrets flake, or a sops/agenix
                    runtime path such as `/run/secrets/...`). The `listen_address` and
                    `port` options still take precedence over any address/port set in
                    this file.
                '';
            };
        };
    };
}
