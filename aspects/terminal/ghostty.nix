{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    options.biryani = {
        programs.terminals.ghostty = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable Ghostty through Home Manager.";
            };

            use_official_package = lib.mkOption {
                type = lib.types.bool;
                description = "Use the Ghostty package from the Ghostty flake input instead of nixpkgs.";
            };

            background_opacity = lib.mkOption {
                type = lib.types.number;
                description = "Background opacity used by Ghostty.";
            };

            background_blur = lib.mkOption {
                type = lib.types.bool;
                description = "Enable Ghostty background blur.";
            };
        };

    };

    config =
        let
            biryani_shells = config.biryani.shells;
            biryani_terminals = config.biryani.programs.terminals;
            biryani_theming = config.biryani.theming;

            terminals_meta = import ../core/metadata/programs/terminals.nix { inherit config inputs pkgs; };
        in
        lib.mkIf (biryani_terminals.enable && biryani_terminals.ghostty.enable) {
            programs.ghostty = {
                enable = true;

                package = terminals_meta.ghostty.pkg;

                enableBashIntegration = lib.mkIf biryani_shells.bash.enable true;
                enableZshIntegration = lib.mkIf biryani_shells.zsh.enable true;
                enableFishIntegration = lib.mkIf biryani_shells.fish.enable true;

                settings = {
                    theme = "Gruvbox Dark";
                    font-family = "${biryani_theming.fonts.main.name}";
                    window-decoration = false;
                    alpha-blending = "linear-corrected";
                    background-opacity = biryani_terminals.ghostty.background_opacity;
                    background-blur = biryani_terminals.ghostty.background_blur;
                };
            };
        };
}
