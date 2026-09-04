{
    pkgs,
    pkgs_stable,
    inputs,
    config,
    user,
}:
inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = {
        inherit inputs pkgs pkgs_stable;

        # The home graph reads the host's `biryani` tree through this special
        # arg, so patching it here is what makes a second account diverge from
        # the host defaults without a second NixOS evaluation.
        biryani = (pkgs.lib.recursiveUpdate config.biryani user.overrides) // {
            user = { inherit (user) username homedir; };
        };
    };
    modules = [ ./home-init.nix ];
}
