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
        settings.General.DeviceID = "bluetooth:004C:0000:0000";
      };

      services.blueman.enable = true;

      environment.systemPackages = [pkgs.bluetuith];
    };
}
