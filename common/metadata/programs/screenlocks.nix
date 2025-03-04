{
  config,
  inputs,
  pkgs,
}: let
  pro_deskenvs = config.propheci.desktop_environments;

  hyprlock_package = (
    if pro_deskenvs.hyprland.use_official_packages
    then inputs.hyprlock.packages."${pkgs.system}".default
    else pkgs.hyprlock
  );
in {
  swaylock = rec {
    pkg = pkgs.swaylock;
    cmd = "${pkg}/bin/swaylock";
    wayland = true;
    x11 = false;
  };
  hyprlock = rec {
    pkg = hyprlock_package;
    cmd = "${pkg}/bin/hyprlock";
    wayland = true;
    x11 = false;
  };
}
