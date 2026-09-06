{ lib, pkgs, ... }: {
    options.biryani.hardware.kdeconnect = {
        enable = lib.mkEnableOption "KDE Connect phone integration";

        package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.kdePackages.kdeconnect-kde;
            defaultText = "pkgs.kdePackages.kdeconnect-kde";
            description = ''
                KDE Connect package. The same package is used by the system
                (firewall and tools) and by the user daemon, so pairing and the
                indicator cannot drift apart.
            '';
        };

        indicator = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
                Run kdeconnect-indicator in the user session. Needs a system
                tray, so turn it off on headless hosts.
            '';
        };
    };
}
