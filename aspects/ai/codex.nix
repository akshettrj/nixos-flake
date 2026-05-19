{ config, lib, ... }:
{
    config =
        let
            biryani_ai = config.biryani.programs.ai;
            biryani_codex = biryani_ai.codex;
        in
        lib.mkIf (biryani_ai.enable && biryani_codex.enable) {
            programs.codex = {
                enable = true;
                enableMcpIntegration = true;
                skills = biryani_ai.skills;
                settings = {
                    mcpServers = lib.mkIf (biryani_codex.mcpServers != null) biryani_codex.mcpServers;
                };
            };

            home.sessionVariables = {
                CODEX_HOME = "${config.xdg.configHome}/codex";
            };
        };
}
