{
    config,
    lib,
    pkgs,
    ...
}:
{
    imports = [ ./options.nix ];

    config =
        let
            biryani_torrent = config.biryani.programs.torrent;
            biryani_user = config.biryani.user;
        in
        lib.mkIf biryani_torrent.enable {
            # Let the primary user read/write the download directory, which is
            # owned by the daemon's group at 0770.
            users.users."${biryani_user.username}".extraGroups = [ config.services.transmission.group ];

            services.transmission = {
                enable = true;
                package = pkgs.transmission_4;

                # Opens the peer port (TCP + UDP) in the firewall when requested.
                openPeerPorts = biryani_torrent.openFirewall;

                settings = {
                    download-dir = biryani_torrent.downloadDir;

                    # incomplete-dir is left at the module default
                    # (${home}/.incomplete). The module pre-creates that path as a
                    # systemd StateDirectory before the service's mount namespace
                    # is set up; a custom nested incomplete-dir would not be
                    # pre-created and would break the sandbox BindPaths.

                    # RPC / web UI stays local-only; tremc and the web UI connect
                    # over localhost so no password is needed for easy UX.
                    rpc-bind-address = "127.0.0.1";
                    rpc-port = biryani_torrent.rpcPort;
                    rpc-authentication-required = false;
                    rpc-whitelist-enabled = true;
                    rpc-whitelist = "127.0.0.1";

                    # Fixed peer port so it lines up with the firewall opening.
                    peer-port = biryani_torrent.peerPort;
                    peer-port-random-on-start = false;
                    port-forwarding-enabled = true;

                    encryption = 1;
                    utp-enabled = true;
                };
            };

            # The Transmission service runs sandboxed and BindPaths the
            # download-dir before its ExecStartPre can create it, so the
            # directory must exist beforehand. The module only pre-creates the
            # default download-dir as a StateDirectory; pre-create whatever
            # downloadDir points at (owned by the daemon user) so custom
            # locations work too.
            systemd.tmpfiles.rules = [
                "d ${biryani_torrent.downloadDir} 0770 ${config.services.transmission.user} ${config.services.transmission.group} - -"
            ];
        };
}
