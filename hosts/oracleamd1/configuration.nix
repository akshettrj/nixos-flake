{ inputs, ... }:
{
    imports = [
        ./disk-config.nix
        ./options.nix
        ./hardware-configuration.nix
        ../../aspects/core/base-system.nix

        "${inputs.private_secrets}/hosts/oracleamd1"
    ];

    # DO NOT DELETE
    system.stateVersion = "23.11";
}
