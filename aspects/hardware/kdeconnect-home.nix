{ config, lib, ... }: {
    imports = [ ./kdeconnect-options.nix ];

    config =
        let
            biryani_kdeconnect = config.biryani.hardware.kdeconnect;
        in
        lib.mkIf biryani_kdeconnect.enable {
            services.kdeconnect = {
                enable = true;
                package = biryani_kdeconnect.package;
                indicator = biryani_kdeconnect.indicator;
            };
        };
}
