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
                    tui = { vim_mode_default = true; };
                    features = { memories = true; };
                    sandbox_mode = "workspace-write";
                };
            };

            home.sessionVariables = {
                CODEX_HOME = "${config.xdg.configHome}/codex";
            };
        };
}
