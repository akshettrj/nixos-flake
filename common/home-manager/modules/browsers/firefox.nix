{
  config,
  lib,
  ...
}: {
  config = let
    pro_browsers = config.propheci.programs.browsers;
  in
    lib.mkIf (pro_browsers.enable && pro_browsers.firefox.enable) {
      programs.firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/.mozilla/firefox";
      };
    };
}
