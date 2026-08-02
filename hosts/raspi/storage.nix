# External USB HDD: WD Elements, 931.5 GiB, GPT, single ext4 partition (sda1).
#
# SAFETY -- READ BEFORE EDITING
# This filesystem already holds ~443 GiB of `cmu_lectures` and there is NO backup
# of it. Everything declared here is additive: the existing filesystem is only
# mounted, never created. Never add `autoFormat` or `formatOptions` to this
# mount, and never manage this disk with disko -- disko wipes whole disks
# declaratively and would destroy the lectures.
#
# `nofail` keeps the Pi bootable when the drive is absent.
#
# Do NOT switch this to `x-systemd.automount`. systemd-tmpfiles refuses to
# canonicalize paths across an autofs mount point and silently skips every rule
# beneath it ("Detected autofs mount point ... Skipping"). That leaves the
# Nextcloud data directories and the `override.config.php` symlink uncreated, and
# `nextcloud-setup` then fails with "config is not owned by user 'nextcloud'".
# A plain mount is required, because systemd-tmpfiles-setup runs after
# local-fs.target and so sees the real filesystem.
{ pkgs, ... }:
let
    mountPoint = "/mnt/hdd";
    # systemd escapes "/mnt/hdd" to the unit name "mnt-hdd.mount".
    mountUnit = "mnt-hdd.mount";
in
{
    fileSystems."${mountPoint}" = {
        device = "/dev/disk/by-uuid/b84ca45b-0b83-4210-93f9-24efbc658a7c";
        fsType = "ext4";
        options = [
            "nofail"
            "x-systemd.device-timeout=30"
            # `nofail` drops this mount's ordering against local-fs.target, so
            # systemd-tmpfiles-setup (which is only After=local-fs.target) would
            # otherwise run first and create the service directories on the SD card,
            # which the HDD then mounts over and hides. Order the mount explicitly.
            "x-systemd.before=systemd-tmpfiles-setup.service"
        ];
    };

    # With `nofail`, a boot without the drive leaves a bare, writable directory at
    # the mount point on the SD card. systemd-tmpfiles would populate it and restic
    # -- which arrives over SSH and so cannot be gated on the mount without risking
    # SSH lockout -- could then fill the SD card with backups that are invisible
    # once the drive returns.
    #
    # Marking the bare directory immutable removes that failure mode: nothing can be
    # created inside it while it is unmounted. Mounting over an immutable directory
    # is unaffected, and the attribute belongs to the SD card's inode, so it never
    # touches the HDD.
    systemd.services.protect-hdd-mountpoint = {
        description = "Keep the bare ${mountPoint} mountpoint immutable while unmounted";
        before = [ mountUnit ];
        requiredBy = [ mountUnit ];
        after = [ "local-fs-pre.target" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
        };
        script = ''
            # Refuse to touch a mounted filesystem: setting +i on the HDD's own root
            # would stop systemd-tmpfiles creating the service directories.
            if ${pkgs.util-linux}/bin/mountpoint -q ${mountPoint}; then
                echo "${mountPoint} is already mounted; leaving it alone."
                exit 0
            fi

            mkdir -p ${mountPoint}
            ${pkgs.e2fsprogs}/bin/chattr +i ${mountPoint}
        '';
    };
}
