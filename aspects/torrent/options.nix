{ lib, ... }: {
    # Shared option declaration for the torrent aspect. Imported by both the
    # NixOS module set (system.nix) and the Home Manager module set
    # (home/default.nix) so the shape stays in sync across the daemon and the
    # TUI client without duplicating the declaration.
    options.biryani.programs.torrent = {
        enable = lib.mkEnableOption "Transmission torrent daemon (system service).";

        tremc.enable = lib.mkEnableOption "tremc TUI client for Transmission.";

        downloadDir = lib.mkOption {
            type = lib.types.str;
            default = "/var/lib/transmission/Downloads";
            description = "Directory where completed torrents are stored by the daemon.";
        };

        rpcPort = lib.mkOption {
            type = lib.types.port;
            default = 9091;
            description = "Port for the Transmission RPC / web UI (bound to localhost).";
        };

        peerPort = lib.mkOption {
            type = lib.types.port;
            default = 51413;
            description = "TCP/UDP port used for BitTorrent peer connections.";
        };

        openFirewall = lib.mkEnableOption "opening the Transmission peer port in the firewall (useful for a seedbox with reachable incoming peers).";
    };
}
