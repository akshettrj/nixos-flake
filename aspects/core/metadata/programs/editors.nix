{
    config,
    inputs,
    pkgs,
}:
let
    biryani_editors = config.biryani.programs.editors;

    neovim_package = (
        if biryani_editors.neovim.nightly then
            inputs.neovim.packages."${pkgs.stdenv.hostPlatform.system}".neovim
        else
            pkgs.neovim
    );
    helix_package = (
        if biryani_editors.helix.nightly then
            inputs.helix.packages."${pkgs.stdenv.hostPlatform.system}".helix
        else
            pkgs.helix
    );
in
{
    helix = rec {
        pkg = helix_package;
        cmd = "${pkg}/bin/hx";
    };
    neovim = rec {
        pkg = neovim_package;
        cmd = "${pkg}/bin/nvim";
    };
    zeditor = rec {
        pkg = pkgs.zed-editor;
        cmd = "${pkg}/bin/zeditor";
    };
}
