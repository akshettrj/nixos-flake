{ lib, pkgs }:
let
    mergePython = pkgs.python3.withPackages (ps: [ ps.tomli-w ]);
    mergeScript = pkgs.writeText "merge-mutable-config.py" ''
        import json
        import pathlib
        import sys
        import tomllib

        import tomli_w

        FORMATS = {
            "json": (json.loads, lambda data: json.dumps(data, indent=2) + "\n"),
            "toml": (tomllib.loads, tomli_w.dumps),
        }

        fmt, managed_path, target_path = sys.argv[1], sys.argv[2], sys.argv[3]
        loads, dumps = FORMATS[fmt]
        managed = loads(pathlib.Path(managed_path).read_text())
        target = pathlib.Path(target_path)

        existing = {}
        if target.exists():
            try:
                existing = loads(target.read_text())
            except (ValueError, tomllib.TOMLDecodeError):
                existing = {}


        def merge(base, override):
            out = dict(base)
            for key, value in override.items():
                if isinstance(value, dict) and isinstance(out.get(key), dict):
                    out[key] = merge(out[key], value)
                else:
                    out[key] = value
            return out


        target.parent.mkdir(parents=True, exist_ok=True)
        tmp = target.parent / (target.name + ".tmp")
        tmp.write_text(dumps(merge(existing, managed)))
        tmp.replace(target)
    '';
in
{
    # Home Manager modules symlink generated config files into the read-only nix
    # store, but some tools need to write to their config at runtime (project
    # trust, `/model`, permission grants, ...). This drops the symlink for
    # `fileKey` and instead merges the generated file into a mutable
    # `targetPath` on every activation: runtime keys written by the tool are
    # preserved, nix-managed keys win.
    #
    # Returns a Home Manager config fragment; `name` must be unique per file.
    mkMutableConfig =
        {
            name,
            format,
            fileKey,
            managedSource,
            targetPath,
        }:
        assert lib.assertOneOf "format" format [
            "json"
            "toml"
        ];
        {
            home.file.${fileKey}.enable = lib.mkForce false;

            home.activation."${name}MutableConfig" = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
                run ${mergePython}/bin/python3 ${mergeScript} ${format} \
                    ${managedSource} ${lib.escapeShellArg targetPath}
            '';
        };
}
