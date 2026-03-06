{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_gaming = config.propheci.programs.gaming;
  in lib.mkIf pro_gaming.enable {
    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [ mangohud protonup-qt lutris bottles heroic ];
  };
}
