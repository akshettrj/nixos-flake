{
    config,
    pkgs,
    lib,
    ...
}:
{
    config =
        let
            biryani_theming = config.biryani.theming;
        in
        lib.mkIf (biryani_theming.enable && biryani_theming.gtk) {
            gtk = {
                enable = true;
                cursorTheme = {
                    package = biryani_theming.cursor.package;
                    name = biryani_theming.cursor.name;
                    size = biryani_theming.cursor.size;
                };
                font = {
                    name = biryani_theming.fonts.main.name;
                    size = biryani_theming.fonts.main.size;
                };
                iconTheme = {
                    package = pkgs.papirus-icon-theme;
                    name = "Papirus-Dark";
                };
                theme = {
                    package = pkgs.materia-theme;
                    name = "Materia-dark-compact";
                };
                gtk3 = {
                    bookmarks = [
                        "file:///tmp"
                        "file://${config.home.homeDirectory}/media"
                    ];
                };
                gtk4 = {
                    theme = null;
                };
            };

            home.packages = [ pkgs.lxappearance ];
        };
}
