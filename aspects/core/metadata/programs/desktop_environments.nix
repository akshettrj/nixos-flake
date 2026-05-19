{
    config,
    inputs,
    pkgs,
}:
let
    biryani_desenvs = config.biryani.desktop_environments;

    hyprland_package = (
        if biryani_desenvs.hyprland.use_official_packages then
            inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".hyprland
        else
            pkgs.hyprland
    );
in
{
    hyprland = rec {
        pkg = hyprland_package;
        cmd = "${pkg}/bin/start-hyprland";
    };
}
