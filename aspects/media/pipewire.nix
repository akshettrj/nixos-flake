{
    pkgs,
    lib,
    config,
    ...
}:
{
    options.biryani.services.pipewire.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable PipeWire audio services with PulseAudio compatibility.";
    };

    config =
        let
            biryani_hw = config.biryani.hardware;
            biryani_services = config.biryani.services;
        in
        lib.mkIf biryani_services.pipewire.enable {
            assertions = [
                {
                    assertion = !biryani_hw.pulseaudio.enable;
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

            environment.systemPackages = lib.mkIf config.services.pipewire.pulse.enable [
                pkgs.pulsemixer
                pkgs.pasystray
            ];
        };
}
