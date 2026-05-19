{ config, lib, ... }:
{
    imports = [
        ../home-bridge.nix
        ./bash.nix
        ./fish.nix
        ./nushell.nix
        ./zsh

        ./utils
    ];

    options.biryani = {
        shells = {
            main = lib.mkOption {
                type = lib.types.str;
                description = "Primary interactive shell name.";
            };
            aliases = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                description = "Shell aliases applied across Home Manager shells.";
            };
            bash.enable = lib.mkEnableOption "Bash shell configuration.";
            fish.enable = lib.mkEnableOption "Fish shell configuration.";
            nushell.enable = lib.mkEnableOption "Nushell shell configuration.";
            zsh.enable = lib.mkEnableOption "Zsh shell configuration.";
            eza.enable = lib.mkEnableOption "eza shell integrations.";
            starship.enable = lib.mkEnableOption "Starship prompt.";
            zoxide.enable = lib.mkEnableOption "zoxide directory jumping.";
        };

    };

    config =
        let
            biryani_shells = config.biryani.shells;
        in
        {
            home.shellAliases = biryani_shells.aliases;
        };
}
