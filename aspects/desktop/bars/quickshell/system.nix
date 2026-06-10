{ config, lib, ... }: {
    config =
        let
            biryani_bars = config.biryani.programs.bars;
        in
        lib.mkIf (biryani_bars.enable && biryani_bars.quickshell.enable) { services.upower.enable = true; };
}
