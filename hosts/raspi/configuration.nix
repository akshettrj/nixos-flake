{
    inputs,
    lib,
    pkgs_stable,
    ...
}:
{
    imports = [
        ./options.nix
        ./hardware-configuration.nix
        ../../aspects/core/base-system.nix

        inputs.nixos-hw.nixosModules.raspberry-pi-4

        "${inputs.private_secrets}/hosts/raspi"
    ];

    boot.loader.grub.enable = lib.mkForce false;
    boot.loader.generic-extlinux-compatible.enable = true;

    hardware.enableRedistributableFirmware = true;

    boot.kernelPackages = lib.mkForce pkgs_stable.linuxPackages_rpi4;

    # DO NOT DELETE
    system.stateVersion = "24.05";
}
