{ fetchzip, lib }:
let
    version = "12.0.8.0";
in
# The release zip holds only the plugin assembly; Jellyfin writes its own
# meta.json beside it on first load, so the installed copy must be writable.
fetchzip {
    name = "jellyfin-plugin-intro-skipper-${version}";
    url = "https://github.com/intro-skipper/intro-skipper/releases/download/${lib.versions.majorMinor version}/v${version}/intro-skipper-v${version}.zip";
    hash = "sha256-cX7ygtQOhJdvAcVrpMpdxpyOmZMPQeCAExswme5J18A=";
    stripRoot = false;

    passthru.jellyfinPlugin = {
        name = "Intro Skipper";
        inherit version;
        # Jellyfin ABI this build targets; it will not load on other minors.
        targetAbi = "12.4.0.0";
    };

    meta = {
        description = "Jellyfin plugin that detects intros/credits and exposes them as skippable media segments";
        homepage = "https://github.com/intro-skipper/intro-skipper";
        license = lib.licenses.gpl3Only;
    };
}
