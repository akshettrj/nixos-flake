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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
    };

    # Hyprland related
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprlock = {
      url = "github:hyprwm/hyprlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waybar = {
      url = "github:Alexays/Waybar";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Terminals
    wezterm = {
      url = "github:wez/wezterm?dir=nix";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
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

    watgbridge = {
      url = "github:akshettrj/watgbridge";
    };
    odesli = {
      url = "github:Propheci/odesli-rs?dir=nix";
    };

    nixur.url = "github:Propheci/NixUR";

    rubikoid_base = {
      url = "github:Rubikoid/nix-base";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    common_overlays = [];

    alienrj_pkgs = import nixpkgs {
      system = "x86_64-linux";
      config = {
        allowUnfree = true;
        allowUnsafe = false;
      };
      overlays = common_overlays;
    };

    oracleamperehyd_pkgs = import nixpkgs {
      system = "aarch64-linux";
      config = {
        allowUnfree = false;
        allowUnsafe = false;
      };
      overlays = common_overlays;
    };

    oracleamd1_pkgs = import nixpkgs {
      system = "x86_64-linux";
      config = {
        allowUnfree = false;
        allowUnsafe = false;
      };
      overlays = common_overlays;
    };

    raspi_pkgs = import nixpkgs {
      system = "aarch64-linux";
      config = {
        allowUnfree = false;
        allowUnsafe = false;
      };
      overlays = common_overlays;
    };
  in rec {
    nixosConfigurations = {
      alienrj = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          pkgs_passed = alienrj_pkgs;
        };
        modules = [./hosts/alienrj/configuration.nix];
      };

      oracleamperehyd = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          pkgs_passed = oracleamperehyd_pkgs;
        };
        modules = [
          ./hosts/oracleamperehyd/configuration.nix
          inputs.disko.nixosModules.disko
        ];
      };

      oracleamd1 = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          pkgs_passed = oracleamd1_pkgs;
        };
        modules = [./hosts/oracleamd1/configuration.nix];
      };

      raspi = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          pkgs_passed = raspi_pkgs;
        };
        modules = [./hosts/raspi/configuration.nix];
      };
    };

    homeConfigurations = {
      "${nixosConfigurations.alienrj.config.propheci.user.username}@${nixosConfigurations.alienrj.config.propheci.system.hostname}" =
        import ./common/home-manager/homeManagerMaker.nix
        {
          inherit inputs;
          pkgs = alienrj_pkgs;
          config = nixosConfigurations.alienrj.config;
        };

      "${nixosConfigurations.oracleamperehyd.config.propheci.user.username}@${nixosConfigurations.oracleamperehyd.config.propheci.system.hostname}" =
        import ./common/home-manager/homeManagerMaker.nix
        {
          inherit inputs;
          pkgs = oracleamperehyd_pkgs;
          config = nixosConfigurations.oracleamperehyd.config;
        };

      "${nixosConfigurations.oracleamd1.config.propheci.user.username}@${nixosConfigurations.oracleamd1.config.propheci.system.hostname}" =
        import ./common/home-manager/homeManagerMaker.nix
        {
          inherit inputs;
          pkgs = oracleamd1_pkgs;
          config = nixosConfigurations.oracleamd1.config;
        };

      "${nixosConfigurations.raspi.config.propheci.user.username}@${nixosConfigurations.raspi.config.propheci.system.hostname}" =
        import ./common/home-manager/homeManagerMaker.nix
        {
          inherit inputs;
          pkgs = raspi_pkgs;
          config = nixosConfigurations.raspi.config;
        };
    };

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
