{ biryani, ... }: {
    config.biryani.programs.editors = {
        helix = biryani.programs.editors.helix;
        neovim = biryani.programs.editors.neovim;
        zeditor = biryani.programs.editors.zeditor;
    };
}
