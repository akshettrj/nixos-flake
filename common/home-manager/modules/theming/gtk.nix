{
  config,
  pkgs,
  lib,
  ...
}: {
  config = let
    pro_theming = config.propheci.theming;
    pro_user = config.propheci.user;
  in
    lib.mkIf (pro_theming.enable && pro_theming.gtk) {
      gtk = {
        enable = true;
        cursorTheme = {
          package = pro_theming.cursor.package;
          name = pro_theming.cursor.name;
          size = pro_theming.cursor.size;
        };
        font = {
          name = pro_theming.fonts.main.name;
          size = pro_theming.fonts.main.size;
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
            "file://${pro_user.homedir}/media"
          ];
        };
        gtk4 = {theme = null;};
      };

      home.packages = [pkgs.lxappearance];
    };
}
