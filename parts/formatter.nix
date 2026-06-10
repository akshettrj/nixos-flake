{ ... }: {
    perSystem =
        { pkgs, ... }:
        let
            treefmtConfig = pkgs.writeText "treefmt.toml" ''
                [formatter.nix]
                command = "nixfmt"
                options = ["--indent=4", "--strict", "--verify"]
                includes = ["*.nix"]
            '';
        in
        {
            formatter = pkgs.writeShellApplication {
                name = "nixfmt-4";
                runtimeInputs = [
                    pkgs.nixfmt
                    pkgs.nixfmt-tree
                ];
                text = ''
                    if [ "$#" -eq 0 ]; then
                      set -- .
                    fi

                    exec treefmt --config-file ${treefmtConfig} "$@"
                '';
            };
        };
}
