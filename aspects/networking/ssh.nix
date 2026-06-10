{ config, lib, ... }: {
    options.biryani.services.openssh.server = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable the OpenSSH server.";
        };

        ports = lib.mkOption {
            type = lib.types.listOf lib.types.port;
            example = [ 22 ];
            description = "TCP ports on which the OpenSSH server listens.";
        };

        password_authentication = lib.mkOption {
            type = lib.types.bool;
            description = "Allow password authentication for SSH logins.";
        };

        root_login = lib.mkOption {
            type = lib.types.enum [
                "yes"
                "without-password"
                "prohibit-password"
                "forced-comands-only"
                "no"
            ];
            description = "PermitRootLogin policy for the OpenSSH server.";
        };

        x11_forwarding = lib.mkOption {
            type = lib.types.bool;
            description = "Allow X11 forwarding over SSH.";
        };

        public_keys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Authorized SSH public keys for root and the primary user.";
        };
    };

    config =
        let
            biryani_services = config.biryani.services;
            biryani_user = config.biryani.user;
        in
        lib.mkIf biryani_services.openssh.server.enable {
            services.openssh = {
                enable = true;
                ports = biryani_services.openssh.server.ports;
                settings = {
                    PasswordAuthentication = biryani_services.openssh.server.password_authentication;
                    PermitRootLogin = biryani_services.openssh.server.root_login;
                    X11Forwarding = biryani_services.openssh.server.x11_forwarding;
                };
            };

            users.users.root.openssh.authorizedKeys.keys = biryani_services.openssh.server.public_keys;
            users.users."${biryani_user.username}".openssh.authorizedKeys.keys =
                biryani_services.openssh.server.public_keys;
        };
}
