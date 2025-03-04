{
  config,
  inputs,
  pkgs,
}: let
  pro_terminals = config.propheci.programs.terminals;

  wezterm_package = (
    if pro_terminals.wezterm.use_official_package
    then inputs.wezterm.packages."${pkgs.system}".default
    else pkgs.wezterm
  );

  ghostty_package = (
    if pro_terminals.ghostty.use_official_package
    then inputs.ghostty.packages."${pkgs.system}".default
    else pkgs.ghostty
  );
in {
  alacritty = rec {
    pkg = pkgs.alacritty;
    bin = "${pkg}/bin/alacritty";
    cmd = "${bin}";
    exec = "${cmd} -e";
  };
  wezterm = rec {
    pkg = wezterm_package;
    bin = "${pkg}/bin/wezterm";
    cmd = "${bin} start --always-new-process";
    exec = "${cmd} -e";
  };
  ghostty = rec {
    pkg = ghostty_package;
    bin = pkgs.lib.getBin pkg;
    cmd = "${bin}";
    exec = "${cmd} -e";
  };
}
