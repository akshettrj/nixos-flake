{
    config,
    inputs,
    lib,
    ...
}:
let
    biryani_wuphf = config.biryani.services.self_hosted.wuphf;
    wuphf = config.services.wuphf;

    # The units wuphf's module would run here (a remote one runs on another
    # machine, so it needs no gate on this one).
    running =
        lib.optional wuphf.core.enable "core"
        ++ lib.optional wuphf.misc.enable "misc"
        ++ (
            wuphf.connectors // wuphf.providers
            |> lib.filterAttrs (_: unit: unit.enable && !unit.remote)
            |> lib.attrNames
        );
in
{
    # The core, connectors and providers are services.wuphf.* (wuphf's own
    # module); this aspect gates them and keeps every token in a file outside
    # the store.
    imports = [ inputs.wuphf.nixosModules.default ];

    options.biryani.services.self_hosted.wuphf = {
        enable = lib.mkEnableOption "wuphf, the messaging bridge (its units are services.wuphf.*)";

        secrets_directory = lib.mkOption {
            type = lib.types.str;
            default = "/etc/secrets";
            description = ''
                Directory holding each unit's tokens as wuphf-<id>.env (`NAME=value`
                lines, root-only), kept by hand outside the Nix store.
            '';
        };
    };

    config = lib.mkMerge [
        {
            assertions = [
                {
                    assertion = biryani_wuphf.enable || running == [ ];
                    message = "services.wuphf runs ${lib.concatStringsSep ", " running}; set biryani.services.self_hosted.wuphf.enable.";
                }
            ];
        }
        (lib.mkIf biryani_wuphf.enable {
            services.wuphf.secretsDirectory = lib.mkDefault biryani_wuphf.secrets_directory;
        })
    ];
}
