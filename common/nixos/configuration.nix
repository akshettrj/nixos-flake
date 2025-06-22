{
  config,
  inputs,
  lib,
  pkgs,
  pkgs_unstable,
  ...
}: {
  imports = [
    ../../options.nix
    ./modules

    inputs.nix-index-database.nixosModules.nix-index # Cached database for nix-index
    inputs.nixpkgs.nixosModules.readOnlyPkgs
  ];

  config = let
    pro_nix = config.propheci.nix;
    pro_sec = config.propheci.security;
    pro_shells = config.propheci.shells;
    pro_system = config.propheci.system;
    pro_services = config.propheci.services;
    pro_user = config.propheci.user;

    shells_meta = import ../metadata/programs/shells.nix {inherit pkgs;};
  in {
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };

    boot.loader.efi.canTouchEfiVariables = true;

    boot.tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };

    networking.hostName = pro_system.hostname;
    networking.networkmanager.enable = true;
    networking.firewall = lib.mkIf pro_services.firewall.enable {
      enable = true;
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port] ++ pro_services.firewall.udp_ports;
      allowedTCPPorts = [config.services.tailscale.port] ++ pro_services.firewall.tcp_ports;
    };
    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    time.timeZone = pro_system.time_zone;

    swapDevices = pro_system.swap_devices;

    users.users."${pro_user.username}" = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      initialPassword = "12345";
      shell = shells_meta."${pro_shells.main}".pkg;
    };

    security.sudo.extraRules = lib.mkIf pro_sec.sudo_without_password [
      {
        users = ["${pro_user.username}"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];

    security.polkit.enable = lib.mkIf pro_sec.polkit.enable true;

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      useXkbConfig = true;
    };

    services.libinput.enable = true;
    services.xserver.xkb = {
      layout = "us";
      options = "caps:swapescape";
    };

    nix = {
      nixPath = ["nixpkgs=${inputs.nixpkgs}"];
      settings = {
        experimental-features = "nix-command flakes pipe-operators";
        auto-optimise-store = true;
        extra-substituters =
          [
            "https://propheci.cachix.org"
            "https://watgbridge.cachix.org"
          ]
          ++ lib.optionals pro_nix.nix_community_cache ["https://nix-community.cachix.org"]
          ++ lib.optionals pro_nix.hyprland_cache ["https://hyprland.cachix.org"]
          ++ lib.optionals pro_nix.helix_cache ["https://helix.cachix.org"]
          ++ lib.optionals pro_nix.wezterm_cache ["https://wezterm.cachix.org"];
        extra-trusted-public-keys =
          [
            "propheci.cachix.org-1:CwV87KMySX+rhW88NhTx2hRzdNltV497nhXvWswFGDc="
            "watgbridge.cachix.org-1:KSfgmbSBvXQTpUnoCj21vST7zgwpy3SbNfk0/nesR1Y="
          ]
          ++ lib.optionals pro_nix.nix_community_cache [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ]
          ++ lib.optionals pro_nix.hyprland_cache [
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          ]
          ++ lib.optionals pro_nix.helix_cache [
            "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
          ]
          ++ lib.optionals pro_nix.wezterm_cache [
            "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
          ];
        trusted-users = [
          "root"
          "${pro_user.username}"
        ];
        show-trace = true;
        eval-cache = false;
      };
      gc = lib.mkIf pro_nix.garbage_collection.enable {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    nixpkgs.pkgs = pkgs_unstable;

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
      nixfmt-rfc-style
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
      (inputs.home-manager.packages."${pkgs.system}".default)
    ];

    # Fights with nix-index
    programs.command-not-found.enable = false;
  };
}
