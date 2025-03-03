{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_media = config.propheci.programs.media;
    pro_docs = pro_media.documents;

    pro_theming = config.propheci.theming;
  in
    lib.mkIf (pro_media.enable && pro_docs.zathura.enable) {
      programs.zathura = {
        enable = true;
        package = (
          pkgs.zathura.override {
            useMupdf = pro_docs.zathura.useMupdf;
          }
        );

        mappings = {
          R = "recolor";
          "<Left>" = "navigate previous";
          "<Right>" = "navigate next";
          "<Button8>" = "navigate previous";
          "<Button9>" = "navigate next";
        };

        options = {
          window-title-basename = "true";
          selection-clipboard = "clipboard";
          scroll-page-aware = "true";
          scroll-full-overlap = 1.0e-2;
          zoom-min = 10;
          guioptions = "";
          adjust-open = "width";
          render-loading = "false";
          scroll-step = 50;

          font = "${pro_theming.fonts.main.name} ${toString (pro_theming.fonts.main.size)}";
          default-bg = "#282828";
          default-fg = "#3c3836";

          statusbar-fg = "#bdae93";
          statusbar-bg = "#504945";

          inputbar-bg = "#282828";
          inputbar-fg = "#fbf1c7";

          notification-bg = "#282828";
          notification-fg = "#fbf1c7";

          notification-error-bg = "#282828";
          notification-error-fg = "#fb4934";

          notification-warning-bg = "#282828";
          notification-warning-fg = "#fb4934";

          highlight-color = "#fabd2f";
          highlight-active-color = "#83a598";

          completion-bg = "#3c3836";
          completion-fg = "#83a598";

          completion-highlight-fg = "#fbf1c7";
          completion-highlight-bg = "#83a598";

          recolor-lightcolor = "#282828";
          recolor-darkcolor = "#ebdbb2";

          recolor = "false";
          recolor-keephue = "false";
        };
      };
    };
}
