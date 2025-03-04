{pkgs}: {
  copyq = rec {
    pkg = pkgs.copyq;
    bin = "copyq";
    cmd = "${pkg}/bin/${bin}";
  };
}
