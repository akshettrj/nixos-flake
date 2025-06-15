{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_hw = config.propheci.hardware;
  in
    lib.mkIf pro_hw.graphics.enable {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = [pkgs.mesa];
      };

      services.xserver.videoDrivers = ["fbdev"];
    };
}

