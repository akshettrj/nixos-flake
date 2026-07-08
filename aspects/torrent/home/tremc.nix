{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_torrent = config.biryani.programs.torrent;
        in
        lib.mkIf (biryani_torrent.enable && biryani_torrent.tremc.enable) {
            home.packages = [ pkgs.tremc ];

            # tremc connects to the local daemon over localhost with no auth.
            # Pinning the port here keeps the client in sync with the daemon's
            # rpcPort. tremc uses the terminal's curses colors, so the terminal
            # matugen palette flows through automatically without a dedicated
            # integration.
            xdg.configFile."tremc/settings.cfg".text = ''
                [Connection]
                host = localhost
                port = ${toString biryani_torrent.rpcPort}
                path = /transmission/rpc
                username =
                password =
                ssl = False
            '';
        };
}
