{
    description = "Rust binary crate";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
        fenix.url = "github:nix-community/fenix";
        nix-filter.url = "github:numtide/nix-filter";
    };

    outputs =
        {
            self,
            nixpkgs,
            flake-utils,
            fenix,
            nix-filter,
        }:
        flake-utils.lib.eachDefaultSystem (
            system:
            let
                pkgs = import nixpkgs { inherit system; };

                rustToolchain = fenix.packages."${system}".stable.withComponents [
                    "cargo"
                    "clippy"
                    "rust-src"
                    "rustc"
                    "rustfmt"
                ];
            in
            with pkgs;
            {
                formatter = alejandra;

                devShells.default = mkShell {
                    name = "name";

                    packages = [
                        clang
                        pkg-config
                        rust-analyzer
                        rustToolchain
                        protobuf
                        taplo
                    ];
                };

                packages = rec {
                    name = (
                        pkgs.callPackage ./nix/pkgs/name.nix {
                            inherit nix-filter;
                            toolchain = rustToolchain;
                        }
                    );
                    default = name;
                };
            }
        );
}
