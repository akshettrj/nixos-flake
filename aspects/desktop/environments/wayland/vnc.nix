{
    config,
    lib,
    pkgs,
    ...
}:
{
    # Options declared in the shared file so the schema is defined once for both
    # module graphs. home-bridge.nix forwards the host-set value into this graph.
    imports = [ ./vnc-options.nix ];

    config =
        let
            biryani_vnc = config.biryani.services.vnc;
            biryani_deskenvs = config.biryani.desktop_environments;

            wayvnc_pkg = pkgs.wayvnc;

            # wayvnc reads all authentication settings (password + encryption
            # keys) from its config file, so password auth is enabled by pointing
            # it at the secret-managed config file via --config.
            authArg = lib.optionalString biryani_vnc.auth.enable " --config ${biryani_vnc.auth.config_file}";
        in
        lib.mkIf
            (
                biryani_deskenvs.enable
                && biryani_deskenvs.wayland.enable
                && biryani_deskenvs.hyprland.enable
                && biryani_vnc.enable
            )
            {
                home.packages = [ wayvnc_pkg ];

                assertions = [
                    {
                        assertion = biryani_vnc.auth.enable -> (biryani_vnc.auth.config_file != null);
                        message = "biryani.services.vnc.auth.enable requires biryani.services.vnc.auth.config_file to be set to a wayvnc config file providing the password and encryption keys.";
                    }
                ];

                systemd.user.services.wayvnc = {
                    Unit = {
                        Description = "wayvnc VNC server for the Wayland session";
                        Documentation = "https://github.com/any1/wayvnc";
                        After = [ biryani_vnc.systemd_target ];
                        PartOf = [ biryani_vnc.systemd_target ];
                    };

                    Service = {
                        # Positional address/port keep wayvnc bound to a single
                        # interface. Defaulting to 127.0.0.1 means the server is only
                        # reachable through SSH port forwarding, so no firewall port
                        # needs to be opened.
                        ExecStart = "${lib.getExe wayvnc_pkg}${authArg} ${biryani_vnc.listen_address} ${toString biryani_vnc.port}";
                        Restart = "on-failure";
                        RestartSec = 5;
                    };

                    Install.WantedBy = [ biryani_vnc.systemd_target ];
                };
            };
}
