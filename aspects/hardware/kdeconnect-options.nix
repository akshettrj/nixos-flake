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

        remote_input = {
            enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = ''
                    Let paired phones drive the mouse and keyboard on Hyprland.
                    KDE Connect injects input through the RemoteDesktop portal,
                    which xdg-desktop-portal-hyprland does not implement, so
                    only that interface is routed to `portal_package`. Has no
                    effect outside Hyprland.
                '';
            };

            portal_package = lib.mkOption {
                type = lib.types.package;
                default = pkgs.xdg-desktop-portal-luminous;
                defaultText = "pkgs.xdg-desktop-portal-luminous";
                description = ''
                    Portal backend that serves RemoteDesktop. It must ship a
                    `<name>.portal` file whose name matches `portal_name`.
                '';
            };

            portal_name = lib.mkOption {
                type = lib.types.str;
                default = "luminous";
                description = "Basename of `portal_package`'s `.portal` file, as used in portals.conf.";
            };
        };
    };
}
