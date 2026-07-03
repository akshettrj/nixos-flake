{ lib, pkgs, ... }:
let
    knownShells = lib.attrNames (import ../core/metadata/programs/shells.nix { inherit pkgs; });
in
{
    options.biryani.shells = {
        main = lib.mkOption {
            type = lib.types.enum knownShells;
            description = "Default login shell for the primary user.";
        };

        aliases = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            description = "Shared shell aliases.";
        };

        nushell.enable = lib.mkEnableOption "Nushell.";
        eza.enable = lib.mkEnableOption "eza shell integration.";
        fzf.enable = lib.mkEnableOption "fzf fuzzy finder shell integration.";
        starship.enable = lib.mkEnableOption "Starship prompt.";
        zoxide.enable = lib.mkEnableOption "zoxide directory jumper.";
    };
}
