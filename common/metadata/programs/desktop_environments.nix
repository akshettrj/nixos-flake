{
  config,
  inputs,
  pkgs,
}: let
  pro_desenvs = config.propheci.desktop_environments;

  hyprland_package = (
    if pro_desenvs.hyprland.use_official_packages
    then inputs.hyprland.packages."${pkgs.system}".hyprland
    else pkgs.hyprland
  );
in {
  hyprland = rec {
    pkg = hyprland_package;
    cmd = "${pkg}/bin/Hyprland";
  };
}
