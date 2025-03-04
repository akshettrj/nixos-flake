{pkgs}: {
  bash = rec {
    pkg = pkgs.bash;
    bin = "${pkg}/bin/bash";
  };
  fish = rec {
    pkg = pkgs.fish;
    bin = "${pkg}/bin/fish";
  };
  nushell = rec {
    pkg = pkgs.nushell;
    bin = "${pkg}/bin/nu";
  };
  zsh = rec {
    pkg = pkgs.zsh;
    bin = "${pkg}/bin/zsh";
  };
}
