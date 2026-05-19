{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
let
    knownTerminals = lib.attrNames (
        import ../core/metadata/programs/terminals.nix { inherit config inputs pkgs; }
    );
in
{
    options.biryani.programs.terminals = {
        enable = lib.mkEnableOption "terminal emulator configuration.";

        main = lib.mkOption {
            type = lib.types.enum knownTerminals;
            description = "Primary terminal emulator.";
        };

        backup = lib.mkOption {
            type = lib.types.enum knownTerminals;
            description = "Secondary terminal emulator.";
        };

        wezterm = {
            enable = lib.mkEnableOption "WezTerm.";
            font_size = lib.mkOption {
                type = lib.types.number;
                description = "Font size used by WezTerm.";
            };
            use_official_package = lib.mkOption {
                type = lib.types.bool;
                description = "Use the WezTerm package from the WezTerm flake input instead of nixpkgs.";
            };
            enable_wayland = lib.mkOption {
                type = lib.types.bool;
                description = "Enable WezTerm Wayland support.";
            };
        };

        alacritty = {
            enable = lib.mkEnableOption "Alacritty.";
            font_size = lib.mkOption {
                type = lib.types.number;
                description = "Font size used by Alacritty.";
            };
        };

        ghostty = {
            enable = lib.mkEnableOption "Ghostty.";
            use_official_package = lib.mkOption {
                type = lib.types.bool;
                description = "Use the Ghostty package from the Ghostty flake input instead of nixpkgs.";
            };
            background_opacity = lib.mkOption {
                type = lib.types.number;
                description = "Ghostty background opacity.";
            };
            background_blur = lib.mkOption {
                type = lib.types.bool;
                description = "Enable Ghostty background blur.";
            };
        };
    };
}
