{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.hardware.graphics.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable generic graphics acceleration and Mesa support.";
    };

    config =
        let
            biryani_hw = config.biryani.hardware;
            supports32BitGraphics = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
        in
        lib.mkIf biryani_hw.graphics.enable {
            hardware.graphics = {
                enable = true;
                enable32Bit = supports32BitGraphics;
                extraPackages = [ pkgs.mesa ];
            };

            services.xserver.videoDrivers = [ "fbdev" ];
        };
}
