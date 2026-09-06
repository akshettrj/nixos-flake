{ biryani, ... }: {
    config.biryani.hardware = {
        bluetooth.enable = biryani.hardware.bluetooth.enable;

        kdeconnect = {
            enable = biryani.hardware.kdeconnect.enable;
            package = biryani.hardware.kdeconnect.package;
            indicator = biryani.hardware.kdeconnect.indicator;
        };
    };
}
