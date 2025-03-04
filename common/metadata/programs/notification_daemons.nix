{pkgs}: {
  dunst = rec {
    pkg = pkgs.dunst;
    cmd = "${pkg}/bin/dunst";
  };
}
