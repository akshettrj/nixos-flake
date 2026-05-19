{
    lib,
    makeRustPlatform,
    toolchain,
    nix-filter,
}:
let
    pkgName = "name";

    localSrc = nix-filter {
        pname = pkgName;
        root = ../..;
        include = [
            ../../src
            ../../Cargo.toml
            ../../Cargo.lock
        ];
    };
in
(makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
}).buildRustPackage
    {
        name = pkgName;
        version = "0.1.0";

        src = localSrc;
        cargoLock.lockFile = ../../Cargo.lock;

        meta = with lib; {
            description = "Nix package for ${pkgName}";
            homepage = "Add link here";
            license = licenses.mit;
            mainProgram = pkgName;
        };
    }
