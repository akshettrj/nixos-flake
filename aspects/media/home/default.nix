{ lib, ... }:
{
    imports = [
        ../home-bridge.nix
        ./audio
        ./documents
        ./picture
        ./services
        ./video
    ];

    options.biryani = {
        programs.media = {
            enable = lib.mkEnableOption "Home media programs and services.";
            services.mpris.enable = lib.mkEnableOption "MPRIS command-line controls.";
            audio.mpd = {
                enable = lib.mkEnableOption "MPD music daemon.";
                ncmpcpp.enable = lib.mkEnableOption "ncmpcpp MPD client.";
            };
            video = {
                mpv.enable = lib.mkEnableOption "mpv video player.";
                vlc.enable = lib.mkEnableOption "VLC media player.";
                stremio.enable = lib.mkEnableOption "Stremio streaming client.";
                jellyfin.enable = lib.mkEnableOption "Jellyfin media client.";
            };
            picture = {
                feh.enable = lib.mkEnableOption "feh image viewer.";
                sxiv.enable = lib.mkEnableOption "sxiv image viewer.";
            };
            documents = {
                zathura = {
                    enable = lib.mkEnableOption "Zathura document viewer.";
                    useMupdf = lib.mkOption {
                        type = lib.types.bool;
                        description = "Whether Zathura should use the MuPDF backend.";
                    };
                };
                sioyek.enable = lib.mkEnableOption "Sioyek PDF reader.";
            };
        };

    };
}
