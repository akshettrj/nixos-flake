{ ... }: {
    flake.templates = {
        golang = {
            path = ../templates/golang;
            description = "Go application with a Nix dev shell and gomod2nix packaging";
        };

        python_poetry = {
            path = ../templates/python_poetry;
            description = "Python application with Poetry, Ruff, Pyright, and poetry2nix packaging";
        };

        rust_workspace = {
            path = ../templates/rust_workspace;
            description = "Rust Cargo workspace with a Fenix toolchain dev shell";
        };

        rust = {
            path = ../templates/rust;
            description = "Rust binary crate with a Fenix toolchain and Nix package";
        };

        rust_lib = {
            path = ../templates/rust_lib;
            description = "Rust library crate with a Fenix toolchain dev shell";
        };
    };
}
