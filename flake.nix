{
  description = "My NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # hyprland.url = "github:hyprwm/Hyprland";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    telegram-desktop-userfonts.url = "github:Propheci/nix-telegram-desktop-userfonts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    x86_64-linux-pkgs = import nixpkgs {
      system = "x86_64-linux";
      config = { allowUnfree = true; };
      overlays = [ inputs.neovim-nightly-overlay.overlay ];
    };
  in
  {
    nixosConfigurations = {

      alienrj = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; pkgs = x86_64-linux-pkgs; };
        modules = [ ./hosts/alienrj/configuration.nix ];
      };

      oracleamd2 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; pkgs = x86_64-linux-pkgs; };
        modules = [ ./hosts/oracleamd2/configuration.nix ];
      };

    };
  };
}
