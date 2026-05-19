{
    pkgs,
    lib,
    config,
    ...
}:
{
    options.biryani.hardware.pulseaudio.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable legacy PulseAudio sound support.";
    };

    config =
        let
            biryani_hw = config.biryani.hardware;
            biryani_services = config.biryani.services;
        in
        lib.mkIf biryani_hw.pulseaudio.enable {
            assertions = [
                {
                    assertion = !biryani_services.pipewire.enable;
                    message = "Both pulseaudio and pipewire are enabled. Disable one of them.";
                }
            ];

            hardware.pulseaudio = {
                enable = true;
                support32Bit = true;
            };

            environment.systemPackages = [
                pkgs.pulsemixer
                pkgs.pasystray
            ];
        };
}
