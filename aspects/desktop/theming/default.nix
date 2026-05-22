{ lib, ... }:
{
    imports = [
        ./gtk.nix
        ./matugen.nix
        ./qt.nix
        ./xsession.nix
    ];

    options.biryani.theming = {
        enable = lib.mkEnableOption "Home Manager desktop theming.";
        gtk = lib.mkEnableOption "GTK theming.";
        qt = lib.mkEnableOption "Qt theming through the GTK platform theme.";
        minimum_brightness = lib.mkOption {
            type = lib.types.ints.unsigned;
            description = "Minimum brightness percentage used by brightness helpers.";
        };
        wallpaper = lib.mkOption {
            type = lib.types.path;
            description = "Wallpaper image used by desktop theming modules.";
        };
        cursor = {
            package = lib.mkOption {
                type = lib.types.package;
                description = "Cursor theme package.";
            };
            name = lib.mkOption {
                type = lib.types.str;
                description = "Cursor theme name.";
            };
            size = lib.mkOption {
                type = lib.types.ints.unsigned;
                description = "Cursor size.";
            };
        };
        fonts = {
            main = {
                name = lib.mkOption {
                    type = lib.types.str;
                    description = "Primary UI font family.";
                };
                size = lib.mkOption {
                    type = lib.types.ints.unsigned;
                    description = "Primary UI font size.";
                };
            };
            backups = lib.mkOption {
                type = lib.types.listOf lib.types.attrs;
                description = "Fallback font records used by Home Manager applications.";
            };
        };
    };
}
