{
    description = "Rust Cargo workspace";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
        fenix.url = "github:nix-community/fenix";
    };

    outputs =
        {
            self,
            nixpkgs,
            flake-utils,
            fenix,
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
                    name = "name-workspace";

                    packages = [
                        clang
                        pkg-config
                        rust-analyzer
                        rustToolchain
                        protobuf
                        taplo
                    ];
                };
            }
        );
}
