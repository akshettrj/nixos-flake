{inputs, ...}: {
  imports = [
    ./options.nix
    ./hardware-configuration.nix
    ./specialisation.nix
    ../../common/nixos/configuration.nix

    "${inputs.propheci_secrets}/hosts/alienrj"
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # DO NOT DELETE
  system.stateVersion = "23.11";
}
