{ pkgs }:
{
    brave = rec {
        pkg = pkgs.brave;
        bin = "${pkg}/bin/brave";
        cmd = "brave";
        cmd_shift = "${cmd} --force-device-scale-factor=1";
    };
    chrome = rec {
        pkg = pkgs.google-chrome;
        bin = "${pkg}/bin/google-chrome-stable";
        cmd = "google-chrome-stable";
        cmd_shift = cmd;
    };
    chromium = rec {
        pkg = pkgs.chromium;
        bin = "${pkg}/bin/chromium";
        cmd = "chromium";
        cmd_shift = cmd;
    };
    firefox = rec {
        pkg = pkgs.firefox;
        bin = "${pkg}/bin/firefox";
        cmd = "firefox";
        cmd_shift = cmd;
    };
}
