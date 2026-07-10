{ inputs, ... }: {
    imports = [
        ./disk-config.nix
        ./options.nix
        ./hardware-configuration.nix
        ../../aspects/core/base-system.nix

        "${inputs.private_secrets}/hosts/oracleamd1ca"
    ];

    # DO NOT DELETE
    system.stateVersion = "24.11";
}
