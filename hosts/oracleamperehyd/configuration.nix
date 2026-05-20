{ config, inputs, ... }:
{
    imports = [
        ./options.nix
        ./disk-config.nix
        ./hardware-configuration.nix
        ../../aspects/core/base-system.nix

        "${inputs.private_secrets}/hosts/oracleamperehyd"
    ];

    # DO NOT DELETE
    system.stateVersion = "24.11";
}
