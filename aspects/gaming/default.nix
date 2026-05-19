{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.programs.gaming.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable gaming support, Steam, GameMode, and related launchers.";
    };

    config =
        let
            biryani_gaming = config.biryani.programs.gaming;
        in
        lib.mkIf biryani_gaming.enable {
            programs.steam.enable = true;
            programs.steam.gamescopeSession.enable = true;
            programs.gamemode.enable = true;

            environment.systemPackages = with pkgs; [
                mangohud
                protonup-qt
                lutris
                bottles
                heroic
                cabextract
                p7zip
            ];
        };
}
