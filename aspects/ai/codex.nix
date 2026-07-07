{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_ai = config.biryani.programs.ai;
            biryani_codex = biryani_ai.codex;

            # Home Manager's programs.codex module symlinks config.toml into the
            # nix store, but codex needs to write to it at runtime (project
            # trust, notices, ...). We disable the symlink and instead merge the
            # generated settings into a mutable file on every activation:
            # runtime keys written by codex are preserved, nix-managed keys win.
            codexConfigTarget = "/.config/codex/config.toml";
            managedConfig = config.home.file.${codexConfigTarget}.source;
            mergePython = pkgs.python3.withPackages (ps: [ ps.tomli-w ]);
            mergeScript = pkgs.writeText "merge-codex-config.py" ''
                import pathlib
                import sys
                import tomllib

                import tomli_w

                managed_path, target_path = sys.argv[1], sys.argv[2]
                managed = tomllib.loads(pathlib.Path(managed_path).read_text())
                target = pathlib.Path(target_path)

                existing = {}
                if target.exists():
                    try:
                        existing = tomllib.loads(target.read_text())
                    except tomllib.TOMLDecodeError:
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
                tmp.write_text(tomli_w.dumps(merge(existing, managed)))
                tmp.replace(target)
            '';
        in
        lib.mkIf (biryani_ai.enable && biryani_codex.enable) {
            programs.codex = {
                enable = true;
                package = pkgs.llm-agents.codex;
                enableMcpIntegration = true;
                skills = biryani_ai.skills;
                context = ''
                    - On every iteration, send the user a concise list of next steps, including progress updates and the final response.
                    - Other than MPVs, ensure that the code generated is scalable, maintainable and easily extensible.
                '';
                settings = {
                    mcpServers = lib.mkIf (biryani_codex.mcpServers != null) biryani_codex.mcpServers;
                    tui = {
                        vim_mode_default = true;
                    };
                    features = {
                        memories = true;
                    };
                    status_line = [
                        "model-with-reasoning"
                        "current-dir"
                        "reasoning"
                        "git-branch"
                        "branch-changes"
                        "run-state"
                        "permissions"
                        "approval-mode"
                        "context-remaining"
                        "five-hour-limit"
                        "weekly-limit"
                        "task-progress"
                    ];
                };
            };

            home.file.${codexConfigTarget}.enable = lib.mkForce false;

            home.activation.codexMutableConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                run ${mergePython}/bin/python3 ${mergeScript} \
                    ${managedConfig} "${config.xdg.configHome}/codex/config.toml"
            '';

            home.sessionVariables = {
                CODEX_HOME = "${config.xdg.configHome}/codex";
            };
        };
}
