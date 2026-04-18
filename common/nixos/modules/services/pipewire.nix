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
    lib.mkIf pro_services.pipewire.enable {
      assertions = [
        {
          assertion = !pro_hw.pulseaudio.enable;
          message = "Both pulseaudio and pipewire are enabled. Disable one of them.";
        }
      ];

      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        audio.enable = true;
        pulse.enable = true;
      };

      hardware.alsa.enablePersistence = true;

      environment.systemPackages = lib.mkIf config.services.pipewire.pulse.enable [pkgs.pulsemixer pkgs.pasystray];
    };
}
