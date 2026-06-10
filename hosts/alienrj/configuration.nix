{ inputs, ... }: {
    imports = [
        ./options.nix
        ./hardware-configuration.nix
        ./specialisation.nix
        ../../aspects/core/base-system.nix

        "${inputs.private_secrets}/hosts/alienrj"
    ];

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    # DO NOT DELETE
    system.stateVersion = "23.11";
}
