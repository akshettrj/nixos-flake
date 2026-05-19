{
    config,
    pkgs,
    lib,
    ...
}:
{
    config =
        let
            biryani_deskenvs = config.biryani.desktop_environments;
        in
        lib.mkIf (biryani_deskenvs.enable && biryani_deskenvs.wayland.enable) {
            home.packages = with pkgs; [
                wl-clipboard
                wev
            ];
        };
}
