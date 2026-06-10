{ config, lib, ... }: {
    options.biryani =
        let
            inherit (lib) mkOption types;
        in
        {
            system = {
                time_zone = mkOption {
                    type = types.str;
                    example = "Asia/Kolkata";
                    description = "IANA time zone used by this NixOS system.";
                };

                swap_devices = mkOption {
                    type = types.anything;
                    description = "Swap device declarations passed to NixOS swapDevices.";
                };
            };

            security.polkit.enable = mkOption {
                type = types.bool;
                description = "Enable polkit system authorization support.";
            };
        };

    config =
        let
            biryani_sec = config.biryani.security;
            biryani_system = config.biryani.system;
        in
        {
            boot.loader.grub = {
                enable = true;
                device = "nodev";
                efiSupport = true;
                useOSProber = true;
            };

            boot.loader.efi.canTouchEfiVariables = true;

            boot.tmp = {
                useTmpfs = true;
                cleanOnBoot = true;
            };

            time.timeZone = biryani_system.time_zone;
            swapDevices = biryani_system.swap_devices;

            security.polkit.enable = lib.mkIf biryani_sec.polkit.enable true;

            i18n.defaultLocale = "en_US.UTF-8";
            console = {
                font = "Lat2-Terminus16";
                useXkbConfig = true;
            };

            services.libinput.enable = true;
            services.xserver.xkb = {
                layout = "us";
                options = "caps:swapescape";
            };
        };
}
