{
    config,
    lib,
    pkgs,
    ...
}:
{
    imports = [ ./options.nix ];

    config =
        let
            biryani_streaming = config.biryani.programs.streaming;

            obs_plugins_meta = import ../core/metadata/programs/obs_plugins.nix { inherit pkgs; };

            obs_pkg = pkgs.wrapOBS {
                plugins = map (name: obs_plugins_meta."${name}") biryani_streaming.obs.plugins;
            };
        in
        lib.mkIf biryani_streaming.enable {
            assertions = [
                {
                    assertion = biryani_streaming.audio.sinks == [ ] || config.biryani.services.pipewire.enable;
                    message = "Streaming audio sinks are configured but PipeWire is disabled";
                }
            ];

            environment.systemPackages = lib.optionals biryani_streaming.obs.enable [ obs_pkg ];

            services.pipewire.extraConfig.pipewire."91-streaming-sinks" =
                lib.mkIf (biryani_streaming.audio.sinks != [ ])
                    {
                        "context.objects" = map (sink: {
                            factory = "adapter";
                            args = {
                                "factory.name" = "support.null-audio-sink";
                                "node.name" = sink.name;
                                "node.description" = sink.description;
                                "media.class" = "Audio/Sink";
                                "audio.position" = sink.position;
                            };
                        }) biryani_streaming.audio.sinks;
                    };
        };
}
