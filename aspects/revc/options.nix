{ lib, ... }: {
    # Shared option declaration for the reVC aspect. Imported by both the NixOS
    # module set (system.nix) and the Home Manager module set (home/default.nix)
    # so the toggle can be set from a host's options.nix and read from the Home
    # Manager module without duplicating the declaration.
    options.biryani.programs.revc = {
        enable = lib.mkEnableOption "reVC (re Vice City), a reverse-engineered GTA: Vice City engine. Requires the user to supply the original game's assets.";
    };
}
