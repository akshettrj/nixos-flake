{ lib, pkgs, ... }:
let
    knownFileExplorers = lib.attrNames (
        import ../core/metadata/programs/file_explorers.nix { inherit pkgs; }
    );
in
{
    options.biryani.programs.file_explorers = {
        main = lib.mkOption {
            type = lib.types.enum knownFileExplorers;
            description = "Primary terminal file explorer.";
        };

        backup = lib.mkOption {
            type = lib.types.enum knownFileExplorers;
            description = "Secondary terminal file explorer.";
        };

        lf.enable = lib.mkEnableOption "lf terminal file manager.";
        yazi.enable = lib.mkEnableOption "Yazi terminal file manager.";
    };
}
