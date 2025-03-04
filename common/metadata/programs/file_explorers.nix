{pkgs}: {
  lf = rec {
    pkg = pkgs.lf;
    bin = "${pkg}/bin/lf";
  };
  yazi = rec {
    pkg = pkgs.yazi;
    bin = "${pkg}/bin/yazi";
  };
}
