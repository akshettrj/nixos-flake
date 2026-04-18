{
  pkgs,
  lib,
  config,
  ...
}: {
  config = let
    pro_hw = config.propheci.hardware;
    pro_services = config.propheci.services;
  in
    lib.mkIf pro_hw.pulseaudio.enable {
      assertions = [
        {
          assertion = !pro_services.pipewire.enable;
          message = "Both pulseaudio and pipewire are enabled. Disable one of them.";
        }
      ];

      hardware.pulseaudio = {
        enable = true;
        support32Bit = true;
      };

      environment.systemPackages = [pkgs.pulsemixer pkgs.pasystray];
    };
}
