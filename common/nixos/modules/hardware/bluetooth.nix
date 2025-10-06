{
  pkgs,
  lib,
  config,
  ...
}: {
  config = let
    pro_hw = config.propheci.hardware;
  in
    lib.mkIf pro_hw.bluetooth.enable {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings.General.Experimental = true;
      };

      services.blueman.enable = true;

      environment.systemPackages = [pkgs.bluetuith];
    };
}
