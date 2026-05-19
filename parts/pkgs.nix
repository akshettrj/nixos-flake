{ inputs, ... }:
let
    importPkgs =
        pkgsInput:
        {
            system,
            allowUnfree ? false,
            overlays ? [ ],
        }:
        import pkgsInput {
            inherit system overlays;
            config = {
                inherit allowUnfree;
                allowUnsafe = false;
            };
        };
in
{
    flake.lib = {
        mkPkgs =
            {
                system,
                allowUnfree ? false,
                overlays ? [ ],
            }:
            {
                unstable = importPkgs inputs.nixpkgs { inherit system allowUnfree overlays; };
                stable = importPkgs inputs.nixpkgs-stable { inherit system allowUnfree overlays; };
                master = importPkgs inputs.nixpkgs-master { inherit system allowUnfree overlays; };
            };

        mkPkgsFor =
            {
                pkgsInput,
                system,
                allowUnfree ? false,
                overlays ? [ ],
            }:
            importPkgs pkgsInput { inherit system allowUnfree overlays; };
    };

    perSystem =
        { system, ... }:
        {
            _module.args.pkgsStable = importPkgs inputs.nixpkgs-stable {
                inherit system;
                allowUnfree = true;
                overlays = [ ];
            };

            _module.args.pkgsMaster = importPkgs inputs.nixpkgs-master {
                inherit system;
                allowUnfree = true;
                overlays = [ ];
            };
        };
}
