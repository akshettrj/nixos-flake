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

        prime = lib.mkIf pro_hw.nvidia.prime.enable {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };

          intelBusId = pro_hw.nvidia.prime.intelBusId;
          nvidiaBusId = pro_hw.nvidia.prime.nvidiaBusId;
        };
      };
    };
}
