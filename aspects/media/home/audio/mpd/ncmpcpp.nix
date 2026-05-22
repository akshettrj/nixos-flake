{ config, lib, ... }:
{
    config =
        let
            biryani_media = config.biryani.programs.media;
            biryani_mpd = config.biryani.programs.media.audio.mpd;
            biryani_theming = config.biryani.theming;
            palette =
                if biryani_theming.matugen.integrations.ncmpcpp.enable then
                    biryani_theming.palette.matugen
                else
                    biryani_theming.palette.static;
        in
        lib.mkIf (biryani_media.enable && biryani_mpd.enable && biryani_mpd.ncmpcpp.enable) {
            programs.ncmpcpp = {
                enable = true;
                bindings = [
                    {
                        key = "k";
                        command = "scroll_up";
                    }
                    {
                        key = "j";
                        command = "scroll_down";
                    }
                    {
                        key = "shift-up";
                        command = [
                            "select_item"
                            "scroll_up"
                        ];
                    }
                    {
                        key = "shift-down";
                        command = [
                            "select_item"
                            "scroll_down"
                        ];
                    }
                    {
                        key = "l";
                        command = "next_column";
                    }
                    {
                        key = "h";
                        command = "previous_column";
                    }
                ];
                mpdMusicDir = config.xdg.userDirs.music;
                settings = {
                    browser_display_mode = "columns";
                    autocenter_mode = "yes";
                    follow_now_playing_lyrics = "yes";
                    ignore_leading_the = "yes";
                    ignore_diacritics = "yes";
                    default_place_to_search_in = "database";
                    lyrics_directory = "~/.cache/lyrics";
                    allow_for_physical_item_deletion = "yes";

                    colors_enabled = "yes";
                    main_window_color = palette.on_surface;
                    current_item_prefix = "$(${palette.primary})$r";
                    current_item_suffix = "$/r$(end)";
                    header_window_color = palette.primary;
                    volume_color = palette.error;
                    progressbar_color = palette.primary_container;
                    progressbar_elapsed_color = palette.primary;
                    statusbar_color = palette.on_surface;
                    current_item_inactive_column_prefix = "$(${palette.secondary})$r";
                    active_window_border = palette.primary;
                    song_columns_list_format = "(10)[${palette.primary}]{l} (30)[${palette.on_surface}]{t} (30)[${palette.secondary}]{a} (30)[${palette.tertiary}]{b}";
                    song_list_format = "{$(${palette.outline})%n │ $(end)}{$(${palette.secondary})%a - $(end)}{$(${palette.on_surface})%t$(end)}|{$(${palette.on_surface_variant})%f$(end)}$R{$(${palette.tertiary}) │ %b$(end)}{$(${palette.outline}) │ %l$(end)}";

                    ## Alternative Interface ##;
                    alternative_header_first_line_format = "$0$aqqu$/a {$(${palette.secondary})%a$(end) - }{$(${palette.on_surface})%t$(end)}|{$(${palette.on_surface_variant})%f$(end)} $0$atqq$/a$9";
                    alternative_header_second_line_format = "{{$(${palette.tertiary})%b$(end)}{ [$(${palette.outline})%y$(end)]}}|{%D}";
                    user_interface = "alternative";

                    ## Classic Interface ##;
                    song_status_format = " $(${palette.secondary})%a $(end)$(${palette.outline})⟫⟫ $(end)$(${palette.on_surface})%t $(end)$(${palette.outline})⟫⟫ $(end)$(${palette.tertiary})%b$(end) ";

                    ## Visualizer ##;
                    visualizer_data_source = "/tmp/mpd.fifo";
                    visualizer_output_name = "my_fifo";
                    # visualizer_sync_interval = "60";
                    visualizer_type = "wave";
                    visualizer_in_stereo = "yes";
                    visualizer_look = "◆▋";

                    ## Playlist Editor ##;
                    playlist_editor_display_mode = "columns";

                    ## Navigation ##;
                    cyclic_scrolling = "yes";
                    header_text_scrolling = "yes";
                    jump_to_now_playing_song_at_start = "yes";
                    lines_scrolled = "2";

                    ## Other ##;
                    system_encoding = "utf-8";
                    regular_expressions = "extended";

                    ## Selected tracks ##;
                    selected_item_prefix = "* ";
                    discard_colors_if_item_is_selected = "no";

                    ## Seeking ##;
                    incremental_seeking = "yes";
                    seek_time = "1";

                    ## Visibility ##;
                    header_visibility = "yes";
                    statusbar_visibility = "yes";
                    titles_visibility = "yes";

                    ## Progress Bar ##;
                    progressbar_look = "=>-";

                    ## Now Playing ##;
                    now_playing_prefix = "> ";
                    centered_cursor = "yes";

                    # Misc;
                    display_bitrate = "yes";
                    enable_window_title = "yes";
                    empty_tag_marker = "-";
                    ncmpcpp_directory = "${config.xdg.cacheHome}/ncmpcpp";
                    # execute_on_song_change = notify-send --icon ~/.config/dunst/music.png "Now Playing" "$(mpc --format '%title%\n%artist%' current)";
                };
            };
        };
}
