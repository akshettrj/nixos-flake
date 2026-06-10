{ config, lib, ... }: {
    options.biryani.hardware.bluetooth.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Write Home Manager Bluetooth companion configuration.";
    };

    config =
        let
            biryani_hw = config.biryani.hardware;
        in
        lib.mkIf biryani_hw.bluetooth.enable {
            xdg.configFile."bluetuith/bluetuith.conf".text = ''

                {
                    "keybindings": {
                        NavigateUp: 'k',
                        NavigateDown: 'j',
                        NavigateRight: 'l',
                        NavigateLeft: 'h',
                        Quit: 'q',
                    }
                }

            '';
        };
}
