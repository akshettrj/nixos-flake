{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.programs.editors.helix = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Helix at the NixOS system level.";
        };

        nightly = lib.mkOption {
            type = lib.types.bool;
            description = "Use the nightly Helix package where supported by editor modules.";
        };
    };

    config =
        let
            biryani_editors = config.biryani.programs.editors;
        in
        lib.mkIf biryani_editors.helix.enable { environment.systemPackages = [ pkgs.helix ]; };
}
