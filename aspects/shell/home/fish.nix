{ config, lib, ... }: {
    config =
        let
            biryani_shells = config.biryani.shells;
        in
        lib.mkIf biryani_shells.fish.enable {
            programs.fish = {
                enable = true;
            };
        };
}
