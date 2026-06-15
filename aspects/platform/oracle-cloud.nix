{ config, lib, ... }: {
    options.biryani.platform.oracle_cloud.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
            Apply Oracle Cloud Infrastructure (OCI) boot fixes.

            OCI does not persist UEFI NVRAM boot entries across reboots or
            migrations, so a GRUB install that relies on writing EFI variables
            boots once and then disappears. Installing GRUB to the removable
            fallback path (\EFI\BOOT\BOOT{X64,AA64}.EFI) lets the firmware boot
            without any NVRAM entry.
        '';
    };

    config = lib.mkIf config.biryani.platform.oracle_cloud.enable {
        boot.loader.grub.efiInstallAsRemovable = true;
        boot.loader.efi.canTouchEfiVariables = false;
    };
}
