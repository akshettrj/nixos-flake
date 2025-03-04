{pkgs}: {
  flameshot = rec {
    pkg = pkgs.flameshot;
    bin = "${pkg}/bin/flameshot";
    cmd = {
      fullscreen = "${bin} full";
      region = "${bin} gui";
    };
    deps = {
      grim = pkgs.grim;
    };
  };
  hyprshot = rec {
    pkg = pkgs.hyprshot;
    bin = "${pkg}/bin/hyprshot";
    cmd = {
      fullscreen = "${bin} --freeze --mode output --mode active";
      region = "${bin} --freeze --mode region";
    };
    deps = {
      grim = pkgs.grim;
      slurp = pkgs.slurp;
    };
  };
  shotman = rec {
    pkg = pkgs.shotman;
    bin = "${pkg}/bin/shotman";
    cmd = {
      fullscreen = "shotman --capture output";
      region = "shotman --capture region";
    };
    deps = {
      slurp = pkgs.slurp;
    };
  };
  wayshot = rec {
    pkg = pkgs.wayshot;
    bin = "${pkg}/bin/wayshot";
    cmd = {
      fullscreen = "${bin} --cursor";
      region = ''${bin} --cursor --slurp "''$(${deps.slurp}/bin/slurp)"'';
    };
    deps = {
      slurp = pkgs.slurp;
    };
  };
}
