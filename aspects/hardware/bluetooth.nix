{
    pkgs,
    lib,
    config,
    ...
}:
{
    options.biryani.hardware.bluetooth.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable Bluetooth hardware support and the Blueman desktop service.";
    };

    config =
        let
            biryani_hw = config.biryani.hardware;
        in
        lib.mkIf biryani_hw.bluetooth.enable {
            hardware.bluetooth = {
                enable = true;
                powerOnBoot = true;
                settings.General.Experimental = true;
                settings.General.DeviceID = "bluetooth:004C:0000:0000";
            };

            services.blueman.enable = true;

            environment.systemPackages = [ pkgs.bluetuith ];
        };
}
