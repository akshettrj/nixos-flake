{ config, lib, ... }:
{
    options.biryani.theming.gtk = lib.mkOption {
        type = lib.types.bool;
        description = "Enable system GTK integration required by desktop theming.";
    };

    config =
        let
            biryani_theming = config.biryani.theming;
        in
        lib.mkIf (biryani_theming.enable && biryani_theming.gtk) { programs.dconf.enable = true; };
}
