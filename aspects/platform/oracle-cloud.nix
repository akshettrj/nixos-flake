{ config, lib, ... }: {
    options.biryani.platform.oracle_cloud = {
        enable = lib.mkOption {
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

        iscsi = {
            enable = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = ''
                    Enable the open-iscsi initiator daemon so OCI iSCSI-attached
                    block volumes can be connected.

                    OCI attaches non-boot block volumes over iSCSI. The
                    `iscsiadm` login commands shown in the OCI console require a
                    running `iscsid` and a configured initiator IQN, which this
                    toggle provides. Enable it on hosts that mount iSCSI block
                    volumes.
                '';
            };

            initiator_name = lib.mkOption {
                type = lib.types.str;
                default = "iqn.2016-04.com.oracle.cloud:${config.networking.hostName}";
                defaultText = "iqn.2016-04.com.oracle.cloud:\${config.networking.hostName}";
                example = "iqn.1993-08.org.debian:01:1a2b3c4d5e6f";
                description = ''
                    iSCSI initiator IQN advertised by this host. Must be unique
                    per host across the initiators talking to a given target.
                '';
            };
        };
    };

    config =
        let
            oracle = config.biryani.platform.oracle_cloud;
        in
        lib.mkMerge [
            (lib.mkIf oracle.enable {
                boot.loader.grub.efiInstallAsRemovable = true;
                boot.loader.efi.canTouchEfiVariables = false;
            })

            (lib.mkIf (oracle.enable && oracle.iscsi.enable) {
                services.openiscsi = {
                    enable = true;
                    name = oracle.iscsi.initiator_name;
                };
            })
        ];
}
