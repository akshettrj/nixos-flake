{ ... }: {
    # reVC is a per-user desktop game, so all of its wiring lives in the Home
    # Manager side of the aspect (aspects/revc/home). This NixOS module only
    # declares the shared option so a host's options.nix can set
    # `biryani.programs.revc.enable`, which the home-bridge then forwards into
    # Home Manager.
    imports = [ ./options.nix ];
}
