{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_programs = config.propheci.programs;
  in
    lib.mkIf pro_programs.extra_utilities.yt-dlp.enable {
      environment.systemPackages = [pkgs.yt-dlp];
    };
}
