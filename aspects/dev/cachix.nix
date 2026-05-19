{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.dev.cachix.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Install Cachix in the Home Manager profile.";
    };

    config =
        let
            biryani_dev = config.biryani.dev;
        in
        lib.mkIf biryani_dev.cachix.enable { home.packages = [ pkgs.cachix ]; };
}
