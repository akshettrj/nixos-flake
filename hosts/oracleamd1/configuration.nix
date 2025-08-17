{inputs, ...}: {
  imports = [
    ./disk-config.nix
    ./options.nix
    ./hardware-configuration.nix
    ../../common/nixos/configuration.nix

    "${inputs.propheci_secrets}/hosts/oracleamd1"
  ];

  # DO NOT DELETE
  system.stateVersion = "23.11";
}
