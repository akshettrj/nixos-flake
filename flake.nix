{
  description = "Akshett's NixOS configuration flake";

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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    nixos-hw.url = "github:NixOS/nixos-hardware";

    # Hyprland related
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprlock.url = "github:hyprwm/hyprlock";
    waybar.url = "github:Alexays/Waybar";

    # Terminals
    wezterm.url = "github:wez/wezterm?dir=nix";
    ghostty.url = "github:ghostty-org/ghostty";

    # Text editors
    neovim.url = "github:nix-community/neovim-nightly-overlay";
    helix.url = "github:helix-editor/helix";

    # Utilities
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    alejandra.url = "github:kamadorueda/alejandra";

    # Misc
    wallpapers = {
      url = "github:Propheci/wallpapers";
      flake = false;
    };

    propheci_secrets = {
      url = "git+ssh://git@github.com/akshettrj/nixos_flake_secrets.git";
      flake = false;
    };

    watgbridge.url = "github:akshettrj/watgbridge";
    odesli.url = "github:Propheci/odesli-rs?dir=nix";

    nixur.url = "github:Propheci/NixUR";

    rubikoid_base = {
      url = "github:Rubikoid/nix-base";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    ...
  } @ inputs: let
    overlays = [];

    utils = import ./utils.nix { inherit nixpkgs nixpkgs-stable inputs; };

    allConfigurations = utils.mkConfigurations [
      {
        name = "alienrj";
        system = "x86_64-linux";
        allowUnfree = true;
        nixosModules = [./hosts/alienrj/configuration.nix];
      }
      {
        name = "oracleamperehyd";
        system = "aarch64-linux";
        allowUnfree = false;
        nixosModules = [
          ./hosts/oracleamperehyd/configuration.nix
          inputs.disko.nixosModules.disko
        ];
      }
      {
        name = "oracleamd1";
        system = "x86_64-linux";
        allowUnfree = false;
        nixosModules = [./hosts/oracleamd1/configuration.nix];
      }
      {
        name = "raspi";
        system = "aarch64-linux";
        allowUnfree = false;
        nixosModules = [./hosts/raspi/configuration.nix];
      }
    ] overlays;

  in rec {
    inherit allConfigurations;

    nixosConfigurations = nixpkgs.lib.mapAttrs' (name: value:
      nixpkgs.lib.nameValuePair (name) (value.nixosConfiguration)
    ) allConfigurations;

    homeConfigurations = nixpkgs.lib.mapAttrs' (name: value:
      nixpkgs.lib.nameValuePair (value.homeConfiguration.name) (value.homeConfiguration.value)
    ) allConfigurations;

    templates = {
      golang = {
        path = ./templates/golang;
        description = "Flake for Golang devShell and packaging";
      };
      python_poetry = {
        path = ./templates/python_poetry;
        description = "Flake for Python poetry devShell and packaging";
      };
      rust_workspace = {
        path = ./templates/rust_workspace;
        description = "Flake for Cargo workspace libraries";
      };
      rust = {
        path = ./templates/rust;
        description = "Flake for Cargo non-workspace binaries";
      };
      rust_lib = {
        path = ./templates/rust_lib;
        description = "Flake for Cargo non-workspace libraries";
      };
    };
  };
}
