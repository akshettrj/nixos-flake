{ config, lib, ... }:
{
    config =
        let
            biryani_notifiers = config.biryani.programs.notification_daemons;
            biryani_theming = config.biryani.theming;
        in
        lib.mkIf (biryani_notifiers.enable && biryani_notifiers.dunst.enable) {
            services.dunst = {
                enable = true;

                settings = {
                    global = {
                        follow = "mouse";
                        indicate_hidden = true;
                        font = "${biryani_theming.fonts.main.name} ${toString (biryani_notifiers.dunst.font_size)}";
                        line_height = 0;
                        markup = "full";
                        separator_height = 3;
                        padding = 4;
                        frame_width = 2;
                        frame_color = "#aaaaaa";
                        separator_color = "auto";
                        sort = false;
                        idle_threshold = 0;
                        format = "<u><b>[ %a ]</b></u>\n<u>%s%p</u>\n%b";
                        alignment = "center";
                        show_age_threshold = 15;
                        word_wrap = true;
                        ignore_newline = false;
                        stack_duplicates = true;
                        hide_duplicate_count = false;
                        show_indicators = true;
                        icon_position = "left";
                        max_icon_size = 32;
                        startup_notification = true;
                        corner_radius = 2;

                        title = "Dunst";
                        class = "Dunst";

                        mouse_left_click = "do_action";
                        mouse_middle_click = "close_all";
                        mouse_right_click = "close_current";
                    };
                    experimental = {
                        per_monitor_dpi = true;
                    };
                    urgency_low = {
                        background = "#2b2b2b";
                        foreground = "#ffffff";
                        icon = "${./dunst_images/normal.png}";
                    };
                    urgency_normal = {
                        background = "#2b2b2b";
                        foreground = "#ffffff";
                        icon = "${./dunst_images/normal.png}";
                    };
                    urgency_critical = {
                        background = "#900000";
                        foreground = "#ffffff";
                        frame_color = "#ff0000";
                        icon = "${./dunst_images/critical.png}";
                    };
                };
            };
        };
}
