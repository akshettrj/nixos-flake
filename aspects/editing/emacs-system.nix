{
    config,
    inputs,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.programs.editors.emacs.enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable the Emacs daemon service.";
    };

    config =
        let
            biryani_editors = config.biryani.programs.editors;
        in
        lib.mkIf biryani_editors.emacs.enable {
            services.emacs = {
                enable = true;
                install = true;
            };
        };
}
