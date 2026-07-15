{ config, lib, ... }: {
    config =
        let
            biryani_theming = config.biryani.theming;
        in
        lib.mkIf biryani_theming.enable {
            xsession.enable = true;

            home.pointerCursor = {
                enable = true;
                gtk.enable = true;
                x11.enable = true;
                package = biryani_theming.cursor.package;
                name = biryani_theming.cursor.name;
                size = biryani_theming.cursor.size;
            };
        };
}
