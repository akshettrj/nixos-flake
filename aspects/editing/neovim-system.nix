{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.programs.editors.neovim = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable Neovim at the NixOS system level.";
        };

        nightly = lib.mkOption {
            type = lib.types.bool;
            description = "Use the nightly Neovim package where supported by editor modules.";
        };
    };

    config =
        let
            biryani_editors = config.biryani.programs.editors;
        in
        lib.mkIf biryani_editors.neovim.enable {
            programs.neovim = {
                enable = true;
                defaultEditor = if biryani_editors.main == "neovim" then true else false;
            };

            environment.systemPackages = [ pkgs.neovim ];
        };
}
