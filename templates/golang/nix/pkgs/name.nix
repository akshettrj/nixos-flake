{
    lib,
    buildGoApplication,
    nix-filter,
    self,
}:
let
    localSrc = nix-filter {
        name = "name-src";
        root = ../../.;
        include = [
            ../../go.mod
            ../../go.sum
            ../../gomod2nix.toml
            ../../cmd
            ../../internal
            ../../pkg
            ../../main.go
        ];
    };

    lastReleaseVersion = "0.0.0";

    devVersion = (
        if (builtins.hasAttr "shortRev" self) then
            self.shortRev
        else if (builtins.hasAttr "dirtyShortRev" self) then
            self.dirtyShortRev
        else
            "dev"
    );
in
buildGoApplication {
    pname = "name";
    version = devVersion;

    src = localSrc;
    pwd = localSrc;

    ldflags = [
        "-s"
        "-w"
    ];

    meta = with lib; rec {
        description = "Add description here";
        homepage = "Add link here";
        changelog = "${homepage}/compare/v${lastReleaseVersion}...main";
        license = licenses.mit;
        mainProgram = "name";
    };
}
