{ config, lib, ... }: {
    imports = [ ./kdeconnect-options.nix ];

    config =
        let
            biryani_kdeconnect = config.biryani.hardware.kdeconnect;
        in
        lib.mkIf biryani_kdeconnect.enable {
            # Installs the package and opens the UDP/TCP 1714-1764 range that
            # device discovery and pairing need.
            programs.kdeconnect = {
                enable = true;
                package = biryani_kdeconnect.package;
            };
        };
}
