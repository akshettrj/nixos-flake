{
    config,
    inputs,
    lib,
    pkgs,
    biryani,
    ...
}:
let
    biryaniDesktops = biryani.desktop_environments;
in
{
    config.xdg = {
        portal = lib.mkIf biryani.services.xdg_portal.enable {
            enable = true;
            config = {
                common.default = [ "gtk" ];
                hyprland.default = [
                    "gtk"
                    "hyprland"
                ];
            };
            extraPortals = [
                pkgs.xdg-desktop-portal-gtk
            ]
            ++ lib.optionals biryaniDesktops.hyprland.enable [
                (
                    if biryaniDesktops.hyprland.use_official_packages then
                        inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".xdg-desktop-portal-hyprland
                    else
                        pkgs.xdg-desktop-portal-hyprland
                )
            ];
        };

        mimeApps = {
            enable = true;
            associations.added = {
                "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
                "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
                "x-scheme-handler/msteams" = [ "teams-for-linux.desktop" ];
            };
            defaultApplications =
                let
                    imageDesktopEntries = [
                        "sxiv.desktop"
                        "feh.desktop"
                    ];
                in
                {
                    "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
                    "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
                    "x-scheme-handler/msteams" = [ "teams-for-linux.desktop" ];
                    "application/pdf" = [
                        "sioyek.desktop"
                        "org.pwmt.zathura-pdf-mupdf.desktop"
                    ];
                    "image/png" = imageDesktopEntries;
                    "image/jpeg" = imageDesktopEntries;
                    "image/webp" = imageDesktopEntries;
                };
        };
    };
}
