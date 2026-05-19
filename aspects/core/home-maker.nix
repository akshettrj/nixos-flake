{
    pkgs,
    pkgs_stable,
    inputs,
    config,
}:
inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = {
        inherit inputs pkgs pkgs_stable;
        biryani = config.biryani;
    };
    modules = [ ./home-init.nix ];
}
