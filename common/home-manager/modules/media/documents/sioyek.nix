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
    lib.mkIf (pro_media.enable && pro_docs.sioyek.enable) {
      programs.sioyek = {
        enable = true;

        bindings = {
          goto_beginning = ["gg" "<c-<home>>"]; # Goto the beginning of document. If prefixed with a number, it will go to that page. For example 150gg goes to page 150.
          goto_end = ["G" "<end>"]; # Goto the end of the document.
          goto_page_with_page_number = "<home>"; # Opens a prompt to enter page number and jump to that page

          goto_left_smart = "^"; # Goto left side of the page ignoring white margins
          goto_right_smart = "$"; # Goto right side of the page ignoring white margins
          "goto_top_of_page;goto_right_smart" = "zz"; # Goto the top-right side of page. Useful for two column documents

          move_left = "<right>";
          move_right = "<left>";

          next_page = ["<c-<pagedown>>" "J"];
          previous_page = ["<c-<pageup>>" "K"];

          screen_down = ["<space>" "<pagedown>"];
          screen_up = ["<s-<space>>" "<pageup>"];

          next_chapter = "gc";
          prev_chapter = "gC";

          next_state = ["<s-<backspace>>" "<c-<right>>"];
          prev_state = ["<backspace>" "<c-<left>>"];

          new_window = "<c-t>";
          close_window = "<c-w>";

          goto_toc = "t";

          zoom_in = "+";
          zoom_out = "-";
          fit_to_page_width = ["=" "<f9>"];
          fit_to_page_width_smart = "<f10>";

          rotate_clockwise = "r";
          rotate_counterclockwise = "R";

          open_document = "o";
          open_prev_doc = "O";
          open_document_embedded = "<c-o>";
          open_document_embedded_from_current_path = "<c-s-o>";

          move_visual_mark_up = ["k" "<up>"];
          move_visual_mark_down = ["j" "<down>"];

          search = ["<c-f>" "/"];
          chapter_search = ["c<c-f>" "c/"];

          next_item = "n";
          previous_item = "N";

          add_bookmark = "b";
          delete_bookmark = "db";

          goto_bookmark = "gb";
          goto_bookmark_g = "gB"; # Global

          add_highlight = "h";
          delete_highlight = "dh";
          goto_highlight = "gh";
          goto_highlight_g = "gH";
          goto_next_highlight = "gnh";
          goto_prev_highlight = "gNh";

          set_mark = "m";
          goto_mark = "`";

          portal = "p";
          delete_portal = "dp";
          goto_portal = ["gp" "<tab>"];
          edit_portal = ["P" "<s-<tab>>"];

          copy = "<c-c>";

          toggle_window_configuration = "<f12>";
          toggle_fullscreen = "<f11>";
          toggle_highlight = "<f1>";
          toggle_dark_mode = "<f8>";
          toggle_synctex = "<f4>";
          toggle_mouse_drag_mode = "<f6>";
          toggle_visual_scroll = "<f7>";
          toggle_presentation_mode = "<f5>";

          command = ":";
          quit = "q";
          open_link = "f";
          external_search = "s";
          keyboard_select = "v";
          keyboard_smart_jump = "F";

          overview_definition = "l";
          goto_definition = "<c-]>";
          portal_to_definition = "]";
        };

        config = {
          check_for_updates_on_startup = "0";
          use_legacy_keybinds = "0";

          background_color = "0.97 0.97 0.97";
          dark_mode_background_color = "0.0 0.0 0.0";
          dark_mode_contrast = "0.8";

          text_highlight_color = "1.0 1.0 1.0";
          visual_mark_color = "0.0 0.0 0.0 0.1";
          search_highlight_color = "0.0 1.0 0.0";
          link_highlight_color = "0.0 0.0 0.1";
          synctex_highlight_color = "1.0 0.0 1.0";

          search_url_s = "https://scholar.google.com/scholar?q=";
          search_url_l = "https://gen.lib.rus.ec/scimag/?q=";
          search_url_g = "https://www.google.com/search?q=";

          middle_click_search_engine = "s";
          shift_middle_click_search_engine = "l";

          zoom_inc_factor = "1.2";

          vertical_move_amount = "1.0";
          horizontal_move_amount = "1.0";
          move_screen_ratio = "0.5";

          flat_toc = "0";

          should_use_multiple_monitors = "0";
          should_load_tutorial_when_no_other_file = "1";
          should_launch_new_instance = "0";
          should_launch_new_window = "1";

          visual_mark_next_page_fraction = "0.75";
          visual_mark_next_page_threshol = "0.25";
          should_draw_unrendered_page = "0";
          rerender_overvie = "1";
          default_dark_mod = "0";
          sort_bookmarks_by_locatio = "1";
          custom_background_colo = "0.180 0.204 0.251";
          custom_text_colo = "0.847 0.871 0.914";
          wheel_zoom_on_curso = "0";
          fit_to_page_width_rati = "0.75";
          collapsed_to = "0";
          ruler_mod = "1";
          ruler_paddin = "1.0";
          ruler_x_paddin = "5.0";
          create_table_of_contents_if_not_exist = "1";
          max_created_toc_siz = "5000";
          should_warn_about_user_key_overrid = "1";
          single_click_selects_word = "0";
          multiline_menu = "1";
          prerender_next_page_presentatio = "1";
          highlight_color_a = "0.94 0.64 1.00";
          highlight_color_b = "0.00 0.46 0.86";
          highlight_color_c = "0.60 0.25 0.00";
          highlight_color_d = "0.30 0.00 0.36";
          highlight_color_e = "0.10 0.10 0.10";
          highlight_color_f = "0.00 0.36 0.19";
          highlight_color_g = "0.17 0.81 0.28";
          highlight_color_h = "1.00 0.80 0.60";
          highlight_color_i = "0.50 0.50 0.50";
          highlight_color_j = "0.58 1.00 0.71";
          highlight_color_k = "0.56 0.49 0.00";
          highlight_color_l = "0.62 0.80 0.00";
          highlight_color_m = "0.76 0.00 0.53";
          highlight_color_n = "0.00 0.20 0.50";
          highlight_color_o = "1.00 0.64 0.02";
          highlight_color_p = "1.00 0.66 0.73";
          highlight_color_q = "0.26 0.40 0.00";
          highlight_color_r = "1.00 0.00 0.06";
          highlight_color_s = "0.37 0.95 0.95";
          highlight_color_t = "0.00 0.60 0.56";
          highlight_color_u = "0.88 1.00 0.40";
          highlight_color_v = "0.45 0.04 1.00";
          highlight_color_w = "0.60 0.00 0.00";
          highlight_color_x = "1.00 1.00 0.50";
          highlight_color_y = "1.00 1.00 0.00";
          highlight_color_z = "1.00 0.31 0.02";
        };
      };
    };
}
