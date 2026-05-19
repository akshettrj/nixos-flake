{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.programs.editors = {
        neovim = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Install Neovim through Home Manager.";
            };

            nightly = lib.mkOption {
                type = lib.types.bool;
                description = "Use the nightly Neovim package where supported by editor modules.";
            };
        };

        helix = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Install Helix through Home Manager.";
            };

            nightly = lib.mkOption {
                type = lib.types.bool;
                description = "Use the nightly Helix package where supported by editor modules.";
            };
        };

        zeditor.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Install Zed through Home Manager.";
        };
    };

    config =
        let
            biryani_editors = config.biryani.programs.editors;
            editors_meta = import ../core/metadata/programs/editors.nix { inherit config inputs pkgs; };
        in
        {
            home.packages =
                lib.optionals biryani_editors.neovim.enable [
                    editors_meta.neovim.pkg
                    pkgs.tree-sitter
                ]
                ++ lib.optionals biryani_editors.helix.enable [ editors_meta.helix.pkg ]
                ++ lib.optionals biryani_editors.zeditor.enable [ pkgs.zed-editor ];
        };
}
