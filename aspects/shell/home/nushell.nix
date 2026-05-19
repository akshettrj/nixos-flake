{ config, lib, ... }:
{
    config =
        let
            biryani_shells = config.biryani.shells;
        in
        lib.mkIf biryani_shells.nushell.enable {
            programs.nushell = {
                enable = true;
            };
        };
}
