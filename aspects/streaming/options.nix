{ lib, pkgs, ... }:
let
    inherit (lib) mkOption types;

    knownObsPlugins = lib.attrNames (
        import ../core/metadata/programs/obs_plugins.nix { inherit pkgs; }
    );

    sinkType = types.submodule (
        { config, ... }: {
            options = {
                name = mkOption {
                    type = types.str;
                    example = "stream-desktop";
                    description = "PipeWire node name. This is what OBS and pavucontrol match on.";
                };

                description = mkOption {
                    type = types.str;
                    default = config.name;
                    defaultText = "the sink name";
                    example = "Stream Desktop";
                    description = "Human-readable label shown in audio mixers.";
                };

                position = mkOption {
                    type = types.str;
                    default = "FL,FR";
                    description = "Channel layout of the sink.";
                };
            };
        }
    );
in
{
    options.biryani.programs.streaming = {
        enable = lib.mkEnableOption "streaming toolchain";

        obs = {
            enable = lib.mkEnableOption "OBS Studio";

            plugins = mkOption {
                type = types.listOf (types.enum knownObsPlugins);
                default = [ ];
                example = [
                    "pipewire-audio-capture"
                    "vaapi"
                ];
                description = ''
                    OBS plugins to build into the wrapper. Plugins only load from a
                    `wrapOBS` wrapper, and they are ABI-tied to the OBS version, so
                    they are pinned here rather than installed by hand.

                    NVENC needs no plugin; it comes from the NVIDIA driver.
                '';
            };
        };

        audio.sinks = mkOption {
            type = types.listOf sinkType;
            default = [ ];
            example = lib.literalExpression ''
                [
                    {
                        name = "stream-desktop";
                        description = "Stream Desktop";
                    }
                ]
            '';
            description = ''
                Dedicated PipeWire null sinks. Route an application to one of these
                and capture its monitor in OBS to control exactly which audio
                reaches the stream.

                Only needed to *exclude* sources; per-application capture alone is
                covered by the `pipewire-audio-capture` OBS plugin.
            '';
        };
    };
}
