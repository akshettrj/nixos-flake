{ config, lib, ... }: {
    options.biryani.programs.clipboard_managers = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable clipboard manager configuration through Home Manager.";
        };

        copyq.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable CopyQ as the Home Manager clipboard manager service.";
        };
    };

    config =
        let
            biryani_clips = config.biryani.programs.clipboard_managers;
        in
        lib.mkIf (biryani_clips.enable && biryani_clips.copyq.enable) {
            services.copyq = {
                enable = true;
            };
        };
}
