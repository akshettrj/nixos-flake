{ inputs, lib, ... }: {
    # llm-agents.nix exposes its AI coding agents (claude-code, codex,
    # gemini-cli, ...) under the `pkgs.llm-agents` namespace. Compose it with a
    # local overlay so further package customisations can be added here later.
    flake.overlays.default = lib.composeManyExtensions [
        inputs.llm-agents.overlays.default
        (final: prev: {
            # reVC (re Vice City) engine, built from the pinned `revc_src` input
            # since it is no longer available in nixpkgs. Consumed by the revc
            # aspect (aspects/revc).
            reVC = final.callPackage ../aspects/revc/package.nix { revcSrc = inputs.revc_src; };
        })
    ];
}
