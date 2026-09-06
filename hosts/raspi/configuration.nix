{
    inputs,
    lib,
    pkgs_stable,
    ...
}:
let
    linuxKernelPlatform = pkgs_stable.stdenv.hostPlatform.linux-kernel;
in
{
    imports = [
        ./options.nix
        ./hardware-configuration.nix
        ./storage.nix
        ../../aspects/core/base-system.nix

        inputs.nixos-hw.nixosModules.raspberry-pi-4

        inputs.private_secrets.nixosModules.raspi
    ];

    boot.loader.grub.enable = lib.mkForce false;
    boot.loader.generic-extlinux-compatible.enable = true;

    hardware.enableRedistributableFirmware = true;

    boot.kernelPackages = lib.mkForce pkgs_stable.linuxPackages_rpi4;

    # This host evaluates against unstable's NixOS modules but pins the cached stable
    # rpi4 kernel, which predates the `buildDTBs`/`target` passthru those modules read
    # to derive the defaults below. Stable still carries the equivalent values on its
    # platform spec, which unstable has since dropped.
    hardware.deviceTree.enable = linuxKernelPlatform.DTB or false;
    system.boot.loader.kernelFile = linuxKernelPlatform.target;

    # DO NOT DELETE
    system.stateVersion = "24.05";
}
