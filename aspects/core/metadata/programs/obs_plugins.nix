{ pkgs }:
let
    plugins = pkgs.obs-studio-plugins;
in
{
    advanced-scene-switcher = plugins.advanced-scene-switcher;
    backgroundremoval = plugins.obs-backgroundremoval;
    droidcam = plugins.droidcam-obs;
    gstreamer = plugins.obs-gstreamer;
    input-overlay = plugins.input-overlay;
    move-transition = plugins.obs-move-transition;
    multi-rtmp = plugins.obs-multi-rtmp;
    pipewire-audio-capture = plugins.obs-pipewire-audio-capture;
    vaapi = plugins.obs-vaapi;
    vkcapture = plugins.obs-vkcapture;
    wlrobs = plugins.wlrobs;
}
