{pkgs}: {
  bemenu = rec {
    pkg = pkgs.bemenu;
    bin = "${pkg}/bin/bemenu-run";
  };
}
