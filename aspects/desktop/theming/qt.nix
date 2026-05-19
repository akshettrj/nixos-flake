{ config, lib, ... }:
{
    config =
        let
            biryani_theming = config.biryani.theming;
        in
        lib.mkIf (biryani_theming.enable && biryani_theming.qt) {
            qt = {
                enable = true;
                platformTheme.name = "gtk3";
            };
        };
}
