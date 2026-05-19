{ lib, config, ... }:
{
    options.biryani = {
        programs.launchers = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable launcher configuration through Home Manager.";
            };

            bemenu = {
                enable = lib.mkOption {
                    type = lib.types.bool;
                    description = "Enable bemenu as a launcher through Home Manager.";
                };

                font_size = lib.mkOption {
                    type = lib.types.ints.unsigned;
                    description = "Font size used by bemenu.";
                };
            };
        };

    };

    config =
        let
            biryani_launchers = config.biryani.programs.launchers;
            biryani_theming = config.biryani.theming;
        in
        lib.mkIf (biryani_launchers.enable && biryani_launchers.bemenu.enable) {
            programs.bemenu = {
                enable = true;

                settings = {
                    prompt = "Run:";
                    ignorecase = true;
                    hp = biryani_launchers.bemenu.font_size - 4;
                    line-height = biryani_launchers.bemenu.font_size + 20;
                    cw = 2;
                    ch = biryani_launchers.bemenu.font_size + 8;
                    tf = "#268bd2";
                    hf = "#268bd2";
                    hb = "#444444";
                    tb = "#444444";
                    fn = "${biryani_theming.fonts.main.name} ${toString (biryani_launchers.bemenu.font_size)}";
                    no-cursor = true;
                };
            };
        };
}
