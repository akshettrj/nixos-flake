{ config, pkgs, lib, ... }:

{
  options = let
  inherit (lib) mkOption mkEnableOption types;
  in {
    bemenu = {
      enable = mkEnableOption("Whether to enable bemenu");

      fontName = mkOption {
        type = types.str;
        example = "Iosevka NF";
        description = ''
          The font name to be used by bemenu
        '';
      };

      fontSize = mkOption {
        type = types.int;
        example = 14;
        description = ''
          The font size used for bemenu
        '';
      };
    };
  };

  config = {
    programs.bemenu = {
      enable = config.bemenu.enable;
      settings = {
        prompt = "Run: ";
        ignorecase = true;
        hp = config.bemenu.fontSize - 4;
        line-height = config.bemenu.fontSize + 20;
        cw = 2;
        ch = config.bemenu.fontSize + 8;
        tf = "#268bd2";
        hf = "#268bd2";
        hb = "#444444";
        fn = "${config.bemenu.fontName} ${toString(config.bemenu.fontSize)}";
        no-cursor = true;
      };
    };
  };
}
