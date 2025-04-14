{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_hw = config.propheci.hardware;
  in
    lib.mkIf pro_hw.nvidia.enable {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = [pkgs.mesa];
      };

      services.xserver.videoDrivers = ["nvidia"];

      hardware.nvidia = {
        package = pro_hw.nvidia.package;

        modesetting.enable = true;

        powerManagement = {
          enable = false;
        };

        open = false;

        nvidiaSettings = true;
      };
    };
}
