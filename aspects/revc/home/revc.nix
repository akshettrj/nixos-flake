{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_revc = config.biryani.programs.revc;
        in
        lib.mkIf biryani_revc.enable {
            # Installs the `reVC` engine binary on PATH. reVC ships only the open
            # engine and its overlay gamefiles (under
            # ${pkgs.reVC}/share/reVC/gamefiles); the original Vice City assets
            # are proprietary and are not bundled. To play, copy the overlay
            # gamefiles on top of a directory holding the original game's files
            # and launch `reVC` from there.
            home.packages = [ pkgs.reVC ];
        };
}
