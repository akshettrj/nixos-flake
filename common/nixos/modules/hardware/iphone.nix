{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_hw = config.propheci.hardware;
  in
    lib.mkIf pro_hw.iphone.enable {
      services.usbmuxd = {
        enable = true;
        package = pro_hw.iphone.usbmuxd_package;
      };

      environment.systemPackages = with pkgs; [
        libimobiledevice
        ifuse
      ];
    };
}
