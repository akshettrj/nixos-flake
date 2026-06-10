{ inputs, pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        # BASE + BASE-DEVEL
        binutils
        bzip2
        coreutils
        file
        findutils
        gawk
        gcc
        gitFull
        gnugrep
        gnused
        gnutar
        gzip
        iproute2
        iputils
        patch
        pciutils
        pkgconf
        procps
        psmisc
        shadow
        util-linux
        which
        xz

        # Essentials for root
        acpi
        curl
        htop
        jq
        lf
        lshw
        nix-output-monitor
        nixfmt
        tmux
        unzip
        vim
        vimv-rs
        wget
        wormhole-rs
        xdg-utils
        zellij
        zip

        # Extra utilities
        (inputs.home-manager.packages."${pkgs.stdenv.hostPlatform.system}".default)
    ];
}
