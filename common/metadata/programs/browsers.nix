{pkgs}: {
  brave = rec {
    pkg = pkgs.brave;
    bin = "${pkg}/bin/brave";
    cmd = "brave";
  };
  chrome = rec {
    pkg = pkgs.google-chrome;
    bin = "${pkg}/bin/google-chrome-stable";
    cmd = "google-chrome-stable";
  };
  chromium = rec {
    pkg = pkgs.chromium;
    bin = "${pkg}/bin/chromium";
    cmd = "chromium";
  };
  firefox = rec {
    pkg = pkgs.firefox;
    bin = "${pkg}/bin/firefox";
    cmd = "firefox";
  };
}
