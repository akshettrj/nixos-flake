{
    description = "Go application";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
        nix-filter.url = "github:numtide/nix-filter";
        gomod2nix = {
            url = "github:nix-community/gomod2nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        {
            self,
            nixpkgs,
            flake-utils,
            nix-filter,
            gomod2nix,
        }:
        flake-utils.lib.eachDefaultSystem (
            system:
            let
                pkgs = import nixpkgs {
                    inherit system;
                    overlays = [ gomod2nix.overlays.default ];
                };
            in
            {
                formatter = pkgs.alejandra;

                devShells.default = pkgs.mkShell {
                    name = "name";
                    packages = with pkgs; [
                        go
                        go-tools
                        golangci-lint
                        gopls
                        delve
                        gomod2nix.packages."${system}".default
                    ];
                };

                packages = rec {
                    name = pkgs.callPackage ./nix/pkgs/name.nix { inherit nix-filter self; };
                    default = name;
                };
            }
        );
}
