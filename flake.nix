{
    description = "My NixOS & Home Manager configurations";

    nixConfig = {
        extra-substituters = [
            "https://propheci.cachix.org"
            "https://watgbridge.cachix.org"
            "https://nix-community.cachix.org"
            "https://hyprland.cachix.org"
            "https://helix.cachix.org"
            "https://wezterm.cachix.org"
        ];

        extra-trusted-public-keys = [
            "propheci.cachix.org-1:CwV87KMySX+rhW88NhTx2hRzdNltV497nhXvWswFGDc="
            "watgbridge.cachix.org-1:KSfgmbSBvXQTpUnoCj21vST7zgwpy3SbNfk0/nesR1Y="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
            "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
        ];
    };

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
        nixpkgs-master.url = "github:nixos/nixpkgs";

        flake-parts.url = "github:hercules-ci/flake-parts";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        disko.url = "github:nix-community/disko";
        nixos-hw.url = "github:NixOS/nixos-hardware";

        wallpapers = {
            url = "github:Propheci/wallpapers";
            flake = false;
        };

        hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
        hyprpaper.url = "github:hyprwm/hyprpaper";
        hyprlock.url = "github:hyprwm/hyprlock";
        waybar.url = "github:Alexays/Waybar";

        quickshell = {
            url = "github:quickshell-mirror/quickshell";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        wezterm.url = "github:wez/wezterm?dir=nix";
        ghostty.url = "github:ghostty-org/ghostty";

        neovim.url = "github:nix-community/neovim-nightly-overlay";
        helix.url = "github:helix-editor/helix";

        nix-index-database = {
            url = "github:nix-community/nix-index-database";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nur.url = "github:nix-community/NUR";

        propheci_secrets = {
            url = "git+ssh://git@github.com/akshettrj/nixos_flake_secrets.git";
            flake = false;
        };

        watgbridge.url = "github:akshettrj/watgbridge";

        odesli = {
            url = "github:Propheci/odesli-rs?dir=nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nixur.url = "github:Propheci/NixUR";

        rubikoid_base = {
            url = "github:Rubikoid/nix-base";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        awcc = {
            url = "github:akshettrj/AWCC";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        mcp_python = {
            url = "github:akshettrj/personal-mcp-py";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        inputs@{ flake-parts, ... }:
        flake-parts.lib.mkFlake { inherit inputs; } {
            imports = [
                ./parts/hosts.nix
                ./parts/configurations.nix
                ./parts/formatter.nix
                ./parts/overlays.nix
                ./parts/pkgs.nix
                ./parts/systems.nix
                ./parts/templates.nix
            ];

            perSystem =
                { pkgs, ... }:
                {
                    packages.default = pkgs.hello;
                };
        };
}
