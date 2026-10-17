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

            # codex writes to config.toml at runtime (project trust, notices, ...).
            codexConfigFile = "/.config/codex/config.toml";
            mutableConfig = import ./mutable-config.nix { inherit lib pkgs; };
        in
        lib.mkIf (biryani_ai.enable && biryani_codex.enable) (
            lib.mkMerge [
                {
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

                    home.sessionVariables = {
                        CODEX_HOME = "${config.xdg.configHome}/codex";
                    };
                }
                (mutableConfig.mkMutableConfig {
                    name = "codex";
                    format = "toml";
                    fileKey = codexConfigFile;
                    managedSource = config.home.file.${codexConfigFile}.source;
                    targetPath = "${config.xdg.configHome}/codex/config.toml";
                })
            ]
        );
}
