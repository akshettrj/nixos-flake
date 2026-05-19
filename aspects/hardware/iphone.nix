{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.hardware.iphone = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable iPhone and iOS device integration tools.";
        };

        usbmuxd_package = lib.mkOption {
            type = lib.types.package;
            description = "usbmuxd package used for iOS device pairing and access.";
        };
    };

    config =
        let
            biryani_hw = config.biryani.hardware;
        in
        lib.mkIf biryani_hw.iphone.enable {
            services.usbmuxd = {
                enable = true;
                package = biryani_hw.iphone.usbmuxd_package;
            };

            environment.systemPackages = with pkgs; [
                libimobiledevice
                ifuse
            ];
        };
}
