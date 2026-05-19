{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
let
    knownEditors = lib.attrNames (
        import ../core/metadata/programs/editors.nix { inherit config inputs pkgs; }
    );
in
{
    options.biryani.programs.editors = {
        main = lib.mkOption {
            type = lib.types.enum knownEditors;
            example = "neovim";
            description = "Primary editor used for EDITOR, VISUAL, and system defaults.";
        };

        backup = lib.mkOption {
            type = lib.types.enum knownEditors;
            example = "helix";
            description = "Secondary editor available as a fallback.";
        };

        zeditor.enable = lib.mkEnableOption "Zed editor.";
    };
}
