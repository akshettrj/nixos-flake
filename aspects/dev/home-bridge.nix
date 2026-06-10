{ biryani, ... }: {
    config.biryani.dev = {
        cachix.enable = biryani.dev.cachix.enable;
        direnv.enable = biryani.dev.direnv.enable;
        git = biryani.dev.git;
    };
}
