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

        sideloading = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable tools for sideloading non-App Store apps (e.g. installing SideStore).";
            };

            iloader_package = lib.mkOption {
                type = lib.types.package;
                description = "iloader package used to sign and install SideStore and its pairing file.";
            };
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

            environment.systemPackages =
                (with pkgs; [
                    libimobiledevice
                    ifuse
                ])
                ++ lib.optionals biryani_hw.iphone.sideloading.enable [
                    biryani_hw.iphone.sideloading.iloader_package
                ];
        };
}
