{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_media = config.biryani.programs.media;
            biryani_theming = config.biryani.theming;
            biryani_video = config.biryani.programs.media.video;

            ss_dir = "${config.xdg.userDirs.pictures}/screenshots/mpv";
            watch_later_dir = "${config.xdg.stateHome}/mpv/watch_later";
        in
        lib.mkIf (biryani_media.enable && biryani_video.mpv.enable) {
            programs.mpv = {
                enable = true;
                scripts = [
                    pkgs.mpvScripts.uosc # better UI
                    pkgs.mpvScripts.mpris # MPRIS support
                ];
                config = {
                    screenshot-directory = ss_dir;

                    ao = "pulse";

                    save-position-on-quit = true;
                    watch-later-directory = watch_later_dir;

                    slang = "en,eng,unknown";
                    alang = "en,eng,hin";
                    sub-bold = true;

                    cache = true;

                    osd-font = biryani_theming.fonts.main.name;
                    osd-font-size = biryani_theming.fonts.main.size;

                    sub-visibility = true;
                    sub-auto = "all";
                    sub-file-paths = "Subs";
                    sub-font = biryani_theming.fonts.main.name;
                    sub-scale = 0.5;

                    osc = false;
                    osd-bar = false;
                    border = false;
                    video-sync = "display-resample";
                };
                extraInput = ''

                    l seek 5 exact
                    h seek -5 exact
                    q quit
                    p cycle pause                          # toggle pause/playback mode
                    j playlist-next                        # skip to next file
                    k playlist-prev                        # skip to previous file
                    u add sub-delay -0.1                   # subtract 100 ms delay from subs
                    Shift+u add sub-delay +0.1             # add
                    a add audio-delay 0.100                # this changes audio/video sync
                    Shift+a add audio-delay -0.100
                    v add volume 2
                    Shift+v add volume -2
                    s cycle sub                            # cycle through subtitles
                    Shift+s cycle sub down                 # ...backwards
                    f cycle fullscreen                     # toggle fullscreen
                    r async screenshot                     # take a screenshot
                    Shift+r async screenshot video         # screenshot without subtitles
                    t script-message-to seek_to toggle-seeker
                    > add speed 0.1
                    < add speed -0.1
                    . add speed 0.05
                    , add speed -0.05

                    r cycle-values video-aspect-override "16:9" "4:3" "2.35:1" "-1"

                    # Better UI
                    tab script-binding uosc/toggle-ui

                '';
            };
        };
}
